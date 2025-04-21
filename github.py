import falcon
import hashlib
import hmac
import json
import os
import subprocess

own_dir = os.path.dirname(__file__)


class GithubRoutes:
    def __init__(
        self,
        repos: list,
    ):
        self.repos = repos

    def on_post(self, req: falcon.Request, resp: falcon.Response, service_name: str):
        try:
            service_cfg = [
                service
                for service in self.repos
                if service.service_name == service_name
            ][0]
        except IndexError:
            raise falcon.HTTPBadRequest(
                title="Unknown service",
                description=f"Webhook for {service_name=} unknown",
            )
        hub_signature = req.get_header(
            "x-hub-signature-256",
            required=True,
            default="x-hub-signature-256 is missing",
        )

        with req.bounded_stream as rs:
            raw_body = rs.read()
        digest = hmac.new(
            key=service_cfg.gh_secret.encode("utf-8"),
            msg=raw_body,
            digestmod=hashlib.sha256,
        )
        expected_signature = f"sha256={digest.hexdigest()}"
        if not hmac.compare_digest(expected_signature, hub_signature):
            raise falcon.HTTPBadRequest(
                title="Signature unmatched",
                description="Calculated and provided signature didn't match",
            )
        payload = json.load(raw_body)
        action = service_cfg.action

        if payload["action"] != action:
            return falcon.HTTPNotImplemented(
                title="Action not implemented",
                description=f"{payload['action']} not implemented. Implemented {action=}",
            )
        subprocess.Popen(
            [
                service_cfg.path_to_update_script,
                payload,
                *service_cfg.args,
            ]
        )
