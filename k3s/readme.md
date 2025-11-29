``` helmfile -f k3s/helm/metallb/helmfile.yaml apply ```

Wacht todat de metallb is opgestart. (Anders error)

Laad de values:
``` kubectl apply -f k3s/helm/metallb/config/metallb-pool.yaml ```

Start NGINX
``` kubectl apply -f k3s/raw/nginx.yaml ```