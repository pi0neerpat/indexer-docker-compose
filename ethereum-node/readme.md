### Rinkeby GETH node

```bash
export $(grep -v '^#' .env | xargs -0)
docker stack deploy -c rinkeby.yml rinkeby
```
