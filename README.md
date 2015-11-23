# JJFMDB
封装FMDB,使开发者远离SQL语句

# 使用方法
 *  1.Model继承于JJBaseDBModel
 *  2.Operate继承于JJBaseDBOperate
 *  3.重写JJBaseDBOperate的getBindingModelClass和getTableName方法
 *  4.重写JJBaseDBModel的getBindingOperateClass方法
 *
 *  注意:支持的类型,NSString,NSNumber,NSInteger,char,int,short,long long,float,CGFloat,BOOL,NSData,UIImage
