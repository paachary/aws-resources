#!/bin/sh
sudo yum update -y
sudo yum install -y gcc httpd24
sudo service httpd start
sudo chkconfig httpd on
cd /var/www/html
sudo touch health.html; sudo chmod 777 health.html ; echo "<html><h1>Hi there: This is heath page. You are alive.</h1></html>" > health.html
sudo touch index.html; sudo chmod 777 index.html ; echo "<html><h1>Hi there: This is Index page.</h1></html>" > index.html

cd /home/ec2-user

curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip
rm CloudWatchMonitoringScripts-1.2.2.zip

export EDITOR="tee"
echo "*/5 * * * * ~/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --disk-space-util --disk-path=/ --from-cron" | crontab -e

wget http://download.joedog.org/siege/siege-latest.tar.gz
tar xzf siege-latest.tar.gz
rm siege-latest.tar.gz
mv siege-* siege

cd siege/
sudo ./configure
sudo make
sudo make install
sudo ln -sf /home/ec2-user/siege/src/siege /usr/bin/siege

