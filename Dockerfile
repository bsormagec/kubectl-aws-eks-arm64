FROM alpine/helm as builder

FROM amazon/aws-cli

ENV BASE_URL="https://get.helm.sh"
ENV HELM_3_FILE="helm-v3.14.3-linux-arm64.tar.gz"

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/arm64/kubectl && \
    curl -L -o /usr/local/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.14/aws-iam-authenticator_0.6.14_linux_arm64 && \
    chmod +x /usr/local/bin/aws-iam-authenticator && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl && \
    yum install -y gettext jq

RUN kubectl version --client

COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /usr/bin/helm /usr/bin/helm

RUN chmod +x /entrypoint.sh
RUN touch /tmp/config
RUN chmod 600 /tmp/config

ENTRYPOINT ["/entrypoint.sh"]
