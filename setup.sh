docker-compose down
sudo rm -rf data keyfile

USERNAME=shovity
PASSWORD=1234567
MONGODB_HOST_INMEMORY=10.0.0.102:27018
MONGODB_HOST_BACKUP=10.0.0.102:27019

sudo openssl rand -base64 756 > keyfile
sudo chown 999 keyfile
sudo chmod 400 keyfile

docker-compose up -d

echo "Waiting 5s for mongod"
sleep 5

docker-compose exec inmemory mongo --eval="
    rs.initiate({
        _id: 'rs0',
        members:[
            {
                _id: 0,
                host: '${MONGODB_HOST_INMEMORY}',
            },
            {
                _id: 1,
                host: '${MONGODB_HOST_BACKUP}',
                hidden: true,
                priority: 0,
            },
        ]
    });
"

echo "Waiting 10s for setup replication"
sleep 10

docker-compose exec inmemory mongo --eval="
    db.getSiblingDB('admin').createUser({
        user: '${USERNAME}',
        pwd: '${PASSWORD}',
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