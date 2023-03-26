FROM alpine/helm as builder

FROM amazon/aws-cli

ENV BASE_URL="https://get.helm.sh"
ENV HELM_3_FILE="helm-v3.4.2-linux-amd64.tar.gz"

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    curl -L -o /usr/local/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.7/aws-iam-authenticator_0.5.7_linux_amd64 && \
    chmod +x /usr/local/bin/aws-iam-authenticator && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl && \
    yum install -y gettext

RUN kubectl version --client

COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /usr/bin/helm /usr/bin/helm

RUN chmod +x /entrypoint.sh
RUN chmod 600 /tmp/config

ENTRYPOINT ["/entrypoint.sh"]
