## Usage

### Create keyfile
```
sudo openssl rand -base64 756 > keyfile
sudo chown 999 keyfile
sudo chmod 400 keyfile
```

### Start container
```
docker-compose up -d
```

### Setup replication
```
docker-compose exec inmemory mongo --eval="
    rs.initiate({
        _id: 'rs0',
        members:[
            {
                _id: 0,
                host: '10.0.0.102:27018',
            },
            {
                _id: 1,
                host: '10.0.0.102:27019',
                hidden: true,
                priority: 0,
            },
        ]
    })
"
```

### Create user to endable auth mode
```
docker-compose exec inmemory mongo --eval="
    db.getSiblingDB('admin').createUser({
        user: 'your_username',
        pwd: 'your_password',
        roles: [
            {
                role: 'userAdminAnyDatabase',
                db: 'admin',
            },
            {
                role: 'clusterAdmin',
                db: 'admin',
            },
        ]
    })
"
```