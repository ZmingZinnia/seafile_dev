pip install sqlalchemy pillow mysql-python elasticsearch==2.4.0 elasticsearch-dsl==2.2.0
pip install social-auth-core==1.7.0

wget https://raw.githubusercontent.com/haiwen/seahub/${BRANCH}/requirements.txt
wget https://raw.githubusercontent.com/haiwen/seahub/${BRANCH}/test-requirements.txt

pip install -r requirements.txt
pip install -r test-requirements.txt
