copy customer from 's3://awssampledbuswest2/ssbgz/customer' 
credentials 'aws_access_key_id=AKIAIU37WBVMSBSIHLKA;aws_secret_access_key=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' 
gzip region 'us-west-2';

copy dwdate from 's3://awssampledbuswest2/ssbgz/dwdate' 
credentials 'aws_access_key_id=AKIAIU37WBVMSBSIHLKA;aws_secret_access_key=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' 
gzip region 'us-west-2';

copy lineorder from 's3://awssampledbuswest2/ssbgz/lineorder' 
credentials 'aws_access_key_id=AKIAIU37WBVMSBSIHLKA;aws_secret_access_key=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'
gzip region 'us-west-2';

copy part from 's3://awssampledbuswest2/ssbgz/part' 
credentials 'aws_access_key_id=AKIAIU37WBVMSBSIHLKA;aws_secret_access_key=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'
gzip region 'us-west-2';

copy supplier from 's3://awssampledbuswest2/ssbgz/supplier' 
credentials 'aws_access_key_id=AKIAIU37WBVMSBSIHLKA;aws_secret_access_key=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'
gzip region 'us-west-2';
