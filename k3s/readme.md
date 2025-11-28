kubectl apply -f metallb-native.yaml

wait for start
kubectl get pods -n metallb-system
Other debug kubectl get endpoints -n metallb-system

Start metallb
kubectl apply -f k3s/metallb.yaml

Debug:
kubectl get ipaddresspools -n metallb-system
kubectl get l2advertisements -n metallb-system


TEST:
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get svc nginx

curl http://192.168.1.246

Remove Test:
kubectl delete svc nginx
kubectl delete deployment nginx


Actually run NGINX
kubectl apply -f k3s/nginx.yaml