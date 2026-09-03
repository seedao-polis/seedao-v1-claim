# Deploy SeeDAO v1 Claim (Docker + Nginx)

域名：**`https://claim-v1.seedao.xyz`**

架构：

```text
Browser
  → claim-v1.seedao.xyz (宿主机 Nginx TLS)
       → 127.0.0.1:3082 (Docker 容器 seedao-v1-claim，内嵌 Nginx SPA)
```

镜像由 GitHub Actions 构建，服务器**只拉镜像、不编译**。

与同机其它 SeeDAO v1 服务并存时：

| 服务 | COMPOSE_PROJECT_NAME | 宿主机端口 | 容器名 |
| ---- | -------------------- | ---------- | ------ |
| 官网 v1 | `seedao-v1-web` | 3080 | `seedao-website` |
| App | `seedao-v1-app` | 3081 | `seedao-v1-app` |
| Claim | `seedao-v1-claim` | 3082 | `seedao-v1-claim` |

---

## 快速部署（已有 Docker / Nginx 的服务器）

```bash
cd /srv/seedao2/seedao-v1-claim
cp deploy/.env.example deploy/.env
# 编辑 deploy/.env，设置 WEB_IMAGE

sudo mkdir -p /var/www/certbot
sudo cp deploy/nginx/claim-v1.seedao.xyz.conf /etc/nginx/conf.d/claim-v1.seedao.xyz.conf
sudo nginx -t && sudo systemctl reload nginx

echo YOUR_PAT | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
chmod +x deploy/pull-and-up.sh
./deploy/pull-and-up.sh
```

HTTPS：

```bash
sudo certbot --nginx -d claim-v1.seedao.xyz
```

国内服务器若拉 GHCR 较慢，可在仓库 Secrets 配置 Aliyun ACR（`ACR_REGISTRY` / `ACR_NAMESPACE` / `ACR_USERNAME` / `ACR_PASSWORD`），把 `deploy/.env` 的 `WEB_IMAGE` 改成 ACR 地址。

---

## 端口说明

默认宿主机端口 **3082**（容器内仍为 3000），避免与同机 seedao-v1-web（3080）、seedao-v1-app（3081）冲突。

`deploy/.env` 中 `HOST_PORT` 必须与 Nginx `proxy_pass` 一致：

| 文件 | 配置 |
| ---------------------------------------- | ----------------------------------- |
| `deploy/.env` | `HOST_PORT=3082` |
| `/etc/nginx/conf.d/claim-v1.seedao.xyz.conf` | `proxy_pass http://127.0.0.1:3082;` |

---

## 后续更新

CI 构建完成后，在服务器：

```bash
cd /srv/seedao2/seedao-v1-claim
git pull
./deploy/pull-and-up.sh
```

---

## 目录说明

| 文件 | 作用 |
| ---------------------------------------- | ---------------- |
| `docker-compose.yml` | 拉取并运行镜像 |
| `.env.example` | `WEB_IMAGE`、`COMPOSE_PROJECT_NAME` 模板 |
| `pull-and-up.sh` | 一键 pull + up |
| `nginx/claim-v1.seedao.xyz.conf` | 宿主机 HTTP 反代 |
| `nginx/claim-v1.seedao.xyz.https.conf.example` | HTTPS 参考 |
| `docker/nginx.conf` | 镜像内 SPA Nginx |
