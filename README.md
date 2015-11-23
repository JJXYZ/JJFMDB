# JJFMDB
封装FMDB,使开发者远离SQL语句

# 使用方法

* 1.Operate继承于JJBaseDBOperate
* 2.重写JJBaseDBOperate的getBindingModelClass和getTableName方法
* 3.调用JJBaseDBOperate+Methods的方法读写数据库


注意:支持的类型,NSString,NSNumber,NSInteger,char,int,short,long long,float,CGFloat,BOOL,NSData,UIImage
