-- =============================================================
-- SCRM 业务库结构与演示数据
-- 依赖：youlai_admin.sql（系统用户/部门/角色已初始化）
-- =============================================================
USE youlai_admin;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 客户表
-- ----------------------------
DROP TABLE IF EXISTS `biz_customer`;
CREATE TABLE `biz_customer` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '客户姓名',
  `short_name` varchar(50) DEFAULT NULL COMMENT '简称',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `wechat` varchar(64) DEFAULT NULL COMMENT '微信号',
  `email` varchar(128) DEFAULT NULL COMMENT '邮箱',
  `gender` tinyint DEFAULT 0 COMMENT '性别(1-男 2-女 0-保密)',
  `company` varchar(128) DEFAULT NULL COMMENT '公司名称',
  `position` varchar(64) DEFAULT NULL COMMENT '职位',
  `industry` varchar(64) DEFAULT NULL COMMENT '所属行业',
  `level` char(1) DEFAULT 'C' COMMENT '客户等级(A/B/C/D)',
  `source` tinyint DEFAULT 6 COMMENT '来源(1-官网 2-转介绍 3-活动 4-广告 5-主动开发 6-其他)',
  `status` tinyint DEFAULT 1 COMMENT '状态(1-潜在 2-跟进中 3-已成交 4-已流失)',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID(NULL为公海客户)',
  `dept_id` bigint DEFAULT NULL COMMENT '归属部门ID',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `last_follow_time` datetime DEFAULT NULL COMMENT '最近跟进时间',
  `next_follow_time` datetime DEFAULT NULL COMMENT '下次跟进时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_phone` (`phone`) USING BTREE,
  KEY `idx_owner` (`owner_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '客户表';

-- ----------------------------
-- 客户标签表
-- ----------------------------
DROP TABLE IF EXISTS `biz_customer_tag`;
CREATE TABLE `biz_customer_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) NOT NULL COMMENT '标签名称',
  `color` varchar(20) DEFAULT '#409EFF' COMMENT '标签颜色',
  `sort` int DEFAULT 0 COMMENT '排序',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_name` (`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '客户标签表';

-- ----------------------------
-- 客户-标签关联表
-- ----------------------------
DROP TABLE IF EXISTS `rel_customer_tag`;
CREATE TABLE `rel_customer_tag` (
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`customer_id`, `tag_id`) USING BTREE,
  KEY `idx_tag_id` (`tag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '客户标签关联表';

-- ----------------------------
-- 跟进记录表
-- ----------------------------
DROP TABLE IF EXISTS `biz_follow_up`;
CREATE TABLE `biz_follow_up` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `type` tinyint DEFAULT 1 COMMENT '跟进方式(1-电话 2-微信 3-拜访 4-邮件 5-其他)',
  `content` varchar(1000) NOT NULL COMMENT '跟进内容',
  `result` varchar(255) DEFAULT NULL COMMENT '跟进结果',
  `next_follow_time` datetime DEFAULT NULL COMMENT '下次跟进时间',
  `create_by` bigint DEFAULT NULL COMMENT '跟进人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer` (`customer_id`) USING BTREE,
  KEY `idx_create_by` (`create_by`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE,
  KEY `idx_next_follow_time` (`next_follow_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '客户跟进记录表';

-- ----------------------------
-- 商机表
-- ----------------------------
DROP TABLE IF EXISTS `biz_opportunity`;
CREATE TABLE `biz_opportunity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `name` varchar(128) NOT NULL COMMENT '商机名称',
  `amount` decimal(12, 2) DEFAULT 0.00 COMMENT '预计金额',
  `stage` tinyint DEFAULT 1 COMMENT '阶段(1-初步接洽 2-需求确认 3-方案报价 4-商务谈判 5-赢单 6-输单)',
  `probability` tinyint DEFAULT 10 COMMENT '赢单概率(%)',
  `expected_close_date` date DEFAULT NULL COMMENT '预计成交日期',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer` (`customer_id`) USING BTREE,
  KEY `idx_owner` (`owner_id`) USING BTREE,
  KEY `idx_stage` (`stage`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '销售商机表';

-- ----------------------------
-- 合同表
-- ----------------------------
DROP TABLE IF EXISTS `biz_contract`;
CREATE TABLE `biz_contract` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `contract_no` varchar(50) NOT NULL COMMENT '合同编号',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `opportunity_id` bigint DEFAULT NULL COMMENT '关联商机ID',
  `name` varchar(128) NOT NULL COMMENT '合同名称',
  `amount` decimal(12, 2) DEFAULT 0.00 COMMENT '合同金额',
  `sign_date` date DEFAULT NULL COMMENT '签订日期',
  `start_date` date DEFAULT NULL COMMENT '服务开始日期',
  `end_date` date DEFAULT NULL COMMENT '服务结束日期',
  `status` tinyint DEFAULT 1 COMMENT '状态(1-草稿 2-执行中 3-已完成 4-已终止)',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_contract_no` (`contract_no`) USING BTREE,
  KEY `idx_customer` (`customer_id`) USING BTREE,
  KEY `idx_owner` (`owner_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '销售合同表';

-- ----------------------------
-- 营销活动表
-- ----------------------------
DROP TABLE IF EXISTS `biz_campaign`;
CREATE TABLE `biz_campaign` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(128) NOT NULL COMMENT '活动名称',
  `type` tinyint DEFAULT 1 COMMENT '类型(1-线上活动 2-线下活动 3-广告投放 4-内容营销)',
  `channel` varchar(64) DEFAULT NULL COMMENT '投放渠道',
  `budget` decimal(12, 2) DEFAULT 0.00 COMMENT '活动预算',
  `start_date` date DEFAULT NULL COMMENT '开始日期',
  `end_date` date DEFAULT NULL COMMENT '结束日期',
  `status` tinyint DEFAULT 0 COMMENT '状态(0-未开始 1-进行中 2-已结束)',
  `target_count` int DEFAULT 0 COMMENT '目标线索数',
  `lead_count` int DEFAULT 0 COMMENT '实际线索数',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '营销活动表';

-- =============================================================
-- 演示数据
-- =============================================================
INSERT INTO `biz_customer` (`id`,`name`,`short_name`,`phone`,`wechat`,`email`,`gender`,`company`,`position`,`industry`,`level`,`source`,`status`,`owner_id`,`dept_id`,`address`,`remark`,`last_follow_time`,`next_follow_time`,`create_by`,`create_time`,`update_by`,`update_time`,`is_deleted`) VALUES
(1,'张伟','海川科技','13800001001','zhangwei_hc','zhangwei@haichuan.cn',1,'杭州海川科技有限公司','采购总监','企业服务','A',2,3,2,1,'杭州市滨江区江南大道 588 号','重点客户，年度采购预算充足',DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_ADD(NOW(), INTERVAL 3 DAY),2,DATE_SUB(NOW(), INTERVAL 86 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(2,'李娜','星辰传媒','13800001002','lina_star','lina@xingchen.com',2,'星辰文化传媒有限公司','市场总监','文化传媒','B',1,2,4,1,'上海市徐汇区漕溪北路 88 号','关注内容营销方案',DATE_SUB(NOW(), INTERVAL 2 DAY),DATE_ADD(NOW(), INTERVAL 2 DAY),4,DATE_SUB(NOW(), INTERVAL 73 DAY),4,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(3,'王强','恒信建材','13800001003','wangqiang_jc',NULL,1,'恒信建材集团','总经理','建筑建材','B',5,2,5,1,'南京市江宁区将军大道 12 号','通过行业展会认识',DATE_SUB(NOW(), INTERVAL 5 DAY),DATE_ADD(NOW(), INTERVAL 1 DAY),5,DATE_SUB(NOW(), INTERVAL 65 DAY),5,DATE_SUB(NOW(), INTERVAL 5 DAY),0),
(4,'刘洋','极客网络','13800001004','liuyang_geek','liuyang@geeknet.cn',1,'极客网络科技有限公司','技术负责人','互联网','A',3,2,2,1,'深圳市南山区科技园南区','对接口集成能力要求高',DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_ADD(NOW(), INTERVAL 4 DAY),2,DATE_SUB(NOW(), INTERVAL 58 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(5,'陈静','悦享餐饮','13800001005','chenjing_yx',NULL,2,'悦享餐饮管理有限公司','运营经理','餐饮连锁','C',3,1,5,1,'成都市武侯区天府三街 66 号','门店会员管理需求',DATE_SUB(NOW(), INTERVAL 9 DAY),DATE_ADD(NOW(), INTERVAL 6 DAY),5,DATE_SUB(NOW(), INTERVAL 51 DAY),5,DATE_SUB(NOW(), INTERVAL 9 DAY),0),
(6,'杨磊','云启软件','13800001006','yanglei_yq','yanglei@yunqi.com',1,'云启软件股份有限公司','副总裁','软件服务','A',2,3,1,1,'北京市海淀区中关村软件园','已签约，等待二期扩容',DATE_SUB(NOW(), INTERVAL 3 DAY),DATE_ADD(NOW(), INTERVAL 10 DAY),1,DATE_SUB(NOW(), INTERVAL 120 DAY),1,DATE_SUB(NOW(), INTERVAL 3 DAY),0),
(7,'赵敏','康泰医疗','13800001007','zhaomin_kt','zhaomin@kangtai.cn',2,'康泰医疗器械有限公司','信息部经理','医疗健康','B',4,2,4,1,'苏州市工业园区星湖街 218 号','数据合规要求严格',DATE_SUB(NOW(), INTERVAL 4 DAY),DATE_ADD(NOW(), INTERVAL 3 DAY),4,DATE_SUB(NOW(), INTERVAL 47 DAY),4,DATE_SUB(NOW(), INTERVAL 4 DAY),0),
(8,'周杰','恒达物流','13800001008','zhoujie_hd',NULL,1,'恒达物流有限公司','业务经理','物流仓储','C',5,1,NULL,NULL,'广州市白云区机场路 1100 号','公海客户，待分配',NULL,NULL,1,DATE_SUB(NOW(), INTERVAL 40 DAY),NULL,NULL,0),
(9,'吴芳','花间集','13800001009','wufang_hj','wufang@huajianji.com',2,'花间集美妆有限公司','创始人','美妆零售','A',3,2,2,1,'杭州市余杭区文一西路 969 号','重视私域运营与会员复购',DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_ADD(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 38 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(10,'徐鹏','远景新能源','13800001010','xupeng_yj',NULL,1,'远景新能源科技有限公司','采购经理','新能源','B',2,2,5,1,'合肥市高新区望江西路 5089 号','正在比较三家供应商',DATE_SUB(NOW(), INTERVAL 6 DAY),DATE_ADD(NOW(), INTERVAL 5 DAY),5,DATE_SUB(NOW(), INTERVAL 36 DAY),5,DATE_SUB(NOW(), INTERVAL 6 DAY),0),
(11,'孙丽','优品电商','13800001011','sunli_yp','sunli@youpin.com',2,'优品电子商务有限公司','运营总监','电子商务','A',1,3,4,1,'上海市浦东新区张江高科','官网留资，转化快',DATE_SUB(NOW(), INTERVAL 7 DAY),DATE_ADD(NOW(), INTERVAL 20 DAY),4,DATE_SUB(NOW(), INTERVAL 34 DAY),4,DATE_SUB(NOW(), INTERVAL 7 DAY),0),
(12,'马超','蓝鲸体育','13800001012','machao_lj',NULL,1,'蓝鲸体育文化有限公司','市场经理','体育文化','C',4,1,NULL,NULL,'武汉市洪山区光谷大道 77 号','公海客户，线索质量待核实',NULL,NULL,1,DATE_SUB(NOW(), INTERVAL 31 DAY),NULL,NULL,0),
(13,'朱琳','万邦咨询','13800001013','zhulin_wb','zhulin@wanbang.cn',2,'万邦管理咨询有限公司','合伙人','企业咨询','B',2,2,5,1,'北京市朝阳区建国路 93 号','希望先做小范围试点',DATE_SUB(NOW(), INTERVAL 8 DAY),DATE_ADD(NOW(), INTERVAL 4 DAY),5,DATE_SUB(NOW(), INTERVAL 29 DAY),5,DATE_SUB(NOW(), INTERVAL 8 DAY),0),
(14,'胡军','华宇地产','13800001014','hujun_hy','hujun@huayu.com',1,'华宇地产集团有限公司','营销副总','房地产','A',3,2,2,1,'重庆市渝北区金开大道 100 号','集团层面决策，周期较长',DATE_SUB(NOW(), INTERVAL 2 DAY),DATE_ADD(NOW(), INTERVAL 7 DAY),2,DATE_SUB(NOW(), INTERVAL 27 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(15,'郭婷','拾光咖啡','13800001015','guoting_sg',NULL,2,'拾光咖啡连锁','品牌经理','餐饮连锁','C',3,1,5,1,'厦门市思明区环岛东路 18 号','新开门店，预算有限',DATE_SUB(NOW(), INTERVAL 12 DAY),DATE_ADD(NOW(), INTERVAL 8 DAY),5,DATE_SUB(NOW(), INTERVAL 25 DAY),5,DATE_SUB(NOW(), INTERVAL 12 DAY),0),
(16,'何伟','卓越教育','13800001016','hewei_zy','hewei@zhuoyue.cn',1,'卓越教育科技有限公司','校长','教育培训','B',1,3,4,1,'西安市雁塔区高新路 25 号','已成交，续费意愿强',DATE_SUB(NOW(), INTERVAL 5 DAY),DATE_ADD(NOW(), INTERVAL 30 DAY),4,DATE_SUB(NOW(), INTERVAL 23 DAY),4,DATE_SUB(NOW(), INTERVAL 5 DAY),0),
(17,'高翔','峰云智能','13800001017','gaoxiang_fy','gaoxiang@fengyun.ai',1,'峰云智能科技有限公司','CEO','人工智能','A',2,2,2,1,'深圳市南山区粤海街道','意向明确，等待方案评审',DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_ADD(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 21 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(18,'林雪','雅诗服饰','13800001018','linxue_ys',NULL,2,'雅诗服饰有限公司','电商负责人','服装零售','B',4,2,4,1,'杭州市萧山区钱江世纪城','关注会员标签体系',DATE_SUB(NOW(), INTERVAL 6 DAY),DATE_ADD(NOW(), INTERVAL 3 DAY),4,DATE_SUB(NOW(), INTERVAL 19 DAY),4,DATE_SUB(NOW(), INTERVAL 6 DAY),0),
(19,'罗刚','中科环保','13800001019','luogang_zk',NULL,1,'中科环保科技有限公司','项目经理','环保科技','C',5,1,NULL,NULL,'天津市滨海新区华苑产业区','公海客户，待电话核实',NULL,NULL,1,DATE_SUB(NOW(), INTERVAL 17 DAY),NULL,NULL,0),
(20,'梁静','宜家装饰','13800001020','liangjing_yj','liangjing@yijia.com',2,'宜家装饰工程有限公司','设计总监','家装设计','B',3,2,5,1,'长沙市岳麓区梅溪湖路 1 号','对移动端体验要求高',DATE_SUB(NOW(), INTERVAL 3 DAY),DATE_ADD(NOW(), INTERVAL 5 DAY),5,DATE_SUB(NOW(), INTERVAL 15 DAY),5,DATE_SUB(NOW(), INTERVAL 3 DAY),0),
(21,'宋涛','天翼通信','13800001021','songtao_ty','songtao@tianyi.cn',1,'天翼通信服务有限公司','政企客户经理','通信服务','A',1,3,1,1,'北京市西城区金融大街 33 号','集团采购，已签约年度服务',DATE_SUB(NOW(), INTERVAL 4 DAY),DATE_ADD(NOW(), INTERVAL 15 DAY),1,DATE_SUB(NOW(), INTERVAL 13 DAY),1,DATE_SUB(NOW(), INTERVAL 4 DAY),0),
(22,'谢娜','米粒母婴','13800001022','xiena_ml',NULL,2,'米粒母婴用品有限公司','社群运营','母婴零售','C',4,1,4,1,'武汉市江汉区解放大道 688 号','已有社群，希望工具化',DATE_SUB(NOW(), INTERVAL 14 DAY),DATE_ADD(NOW(), INTERVAL 9 DAY),4,DATE_SUB(NOW(), INTERVAL 11 DAY),4,DATE_SUB(NOW(), INTERVAL 14 DAY),0),
(23,'唐磊','风行汽车','13800001023','tanglei_fx','tanglei@fengxing.com',1,'风行汽车服务集团','区域经理','汽车服务','B',5,2,2,1,'郑州市金水区农业路 100 号','多门店协同需求',DATE_SUB(NOW(), INTERVAL 2 DAY),DATE_ADD(NOW(), INTERVAL 6 DAY),2,DATE_SUB(NOW(), INTERVAL 8 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(24,'韩梅','四季酒店','13800001024','hanmei_sj',NULL,2,'四季酒店管理有限公司','销售总监','酒店旅游','C',3,1,5,1,'三亚市海棠区海棠北路 88 号','淡季预算审批中',DATE_SUB(NOW(), INTERVAL 10 DAY),DATE_ADD(NOW(), INTERVAL 12 DAY),5,DATE_SUB(NOW(), INTERVAL 5 DAY),5,DATE_SUB(NOW(), INTERVAL 10 DAY),0);

INSERT INTO `biz_customer_tag` (`id`,`name`,`color`,`sort`,`create_by`,`create_time`,`update_by`,`update_time`,`is_deleted`) VALUES
(1,'高意向','#F56C6C',1,1,NOW(),1,NOW(),0),
(2,'价格敏感','#E6A23C',2,1,NOW(),1,NOW(),0),
(3,'关键决策人','#409EFF',3,1,NOW(),1,NOW(),0),
(4,'老客户','#67C23A',4,1,NOW(),1,NOW(),0),
(5,'待回访','#909399',5,1,NOW(),1,NOW(),0),
(6,'已报价','#9B59B6',6,1,NOW(),1,NOW(),0),
(7,'展会线索','#16A085',7,1,NOW(),1,NOW(),0),
(8,'转介绍','#D35400',8,1,NOW(),1,NOW(),0);

INSERT INTO `rel_customer_tag` (`customer_id`,`tag_id`) VALUES
(1,1),(1,3),(1,4),(2,1),(2,8),(3,7),(3,2),(4,1),(4,6),(5,5),(5,2),
(6,4),(6,3),(7,1),(7,3),(7,5),(8,5),(9,1),(9,3),(10,2),(10,6),
(11,1),(11,4),(12,5),(13,2),(13,5),(14,3),(14,1),(15,2),(15,5),(16,4),(16,8),
(17,1),(17,6),(18,5),(19,5),(20,1),(21,4),(21,3),(22,5),(23,1),(23,2),(24,5);

INSERT INTO `biz_follow_up` (`id`,`customer_id`,`type`,`content`,`result`,`next_follow_time`,`create_by`,`create_time`,`update_by`,`update_time`,`is_deleted`) VALUES
(1,1,1,'电话沟通年度框架采购事宜，客户确认预算已审批通过，希望本周看到最终报价。','意向明确',DATE_ADD(NOW(), INTERVAL 3 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(2,1,3,'到客户公司拜访，与技术团队确认对接方案，重点讨论了数据同步频率。','方案待细化',DATE_ADD(NOW(), INTERVAL 5 DAY),2,DATE_SUB(NOW(), INTERVAL 8 DAY),2,DATE_SUB(NOW(), INTERVAL 8 DAY),0),
(3,1,4,'发送产品介绍与成功案例邮件，客户已阅读。','等待反馈',DATE_ADD(NOW(), INTERVAL 10 DAY),2,DATE_SUB(NOW(), INTERVAL 20 DAY),2,DATE_SUB(NOW(), INTERVAL 20 DAY),0),
(4,2,2,'微信沟通内容营销合作方案，客户对短视频投放感兴趣。','需求确认中',DATE_ADD(NOW(), INTERVAL 2 DAY),4,DATE_SUB(NOW(), INTERVAL 2 DAY),4,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(5,2,1,'电话回访，确认下周三安排产品演示。','已约演示',DATE_ADD(NOW(), INTERVAL 5 DAY),4,DATE_SUB(NOW(), INTERVAL 9 DAY),4,DATE_SUB(NOW(), INTERVAL 9 DAY),0),
(6,3,3,'上门拜访总经理，介绍会员运营整体解决方案。','待内部讨论',DATE_ADD(NOW(), INTERVAL 1 DAY),5,DATE_SUB(NOW(), INTERVAL 5 DAY),5,DATE_SUB(NOW(), INTERVAL 5 DAY),0),
(7,3,1,'电话确认需求范围，客户关注门店导购使用体验。','需求补充',DATE_ADD(NOW(), INTERVAL 6 DAY),5,DATE_SUB(NOW(), INTERVAL 15 DAY),5,DATE_SUB(NOW(), INTERVAL 15 DAY),0),
(8,4,2,'微信发送 API 文档，客户技术团队正在评估集成成本。','技术评估',DATE_ADD(NOW(), INTERVAL 4 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(9,4,1,'电话沟通并发量需求，预计日活 5 万。','待报价',DATE_ADD(NOW(), INTERVAL 7 DAY),2,DATE_SUB(NOW(), INTERVAL 12 DAY),2,DATE_SUB(NOW(), INTERVAL 12 DAY),0),
(10,5,2,'微信推送会员小程序案例，客户希望了解餐饮行业版本。','资料已发',DATE_ADD(NOW(), INTERVAL 6 DAY),5,DATE_SUB(NOW(), INTERVAL 9 DAY),5,DATE_SUB(NOW(), INTERVAL 9 DAY),0),
(11,6,3,'季度业务复盘，确认二期扩容 200 个账号。','扩容意向',DATE_ADD(NOW(), INTERVAL 10 DAY),1,DATE_SUB(NOW(), INTERVAL 3 DAY),1,DATE_SUB(NOW(), INTERVAL 3 DAY),0),
(12,6,4,'发送续费与扩容报价单。','已报价',DATE_ADD(NOW(), INTERVAL 8 DAY),1,DATE_SUB(NOW(), INTERVAL 16 DAY),1,DATE_SUB(NOW(), INTERVAL 16 DAY),0),
(13,7,1,'电话沟通医疗数据合规要求，客户关注本地化部署。','合规评估',DATE_ADD(NOW(), INTERVAL 3 DAY),4,DATE_SUB(NOW(), INTERVAL 4 DAY),4,DATE_SUB(NOW(), INTERVAL 4 DAY),0),
(14,7,2,'微信补充等保三级相关材料。','资料已发',DATE_ADD(NOW(), INTERVAL 9 DAY),4,DATE_SUB(NOW(), INTERVAL 18 DAY),4,DATE_SUB(NOW(), INTERVAL 18 DAY),0),
(15,9,3,'到店沟通私域运营方案，客户已有 8 万会员。','方案认可',DATE_ADD(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(16,9,2,'微信确认标签体系设计稿，客户提出按消费频次分层。','设计调整',DATE_ADD(NOW(), INTERVAL 4 DAY),2,DATE_SUB(NOW(), INTERVAL 7 DAY),2,DATE_SUB(NOW(), INTERVAL 7 DAY),0),
(17,10,1,'电话跟进，客户正在对比三家供应商，强调交付周期。','竞争中',DATE_ADD(NOW(), INTERVAL 5 DAY),5,DATE_SUB(NOW(), INTERVAL 6 DAY),5,DATE_SUB(NOW(), INTERVAL 6 DAY),0),
(18,10,4,'发送实施计划与交付里程碑。','已报价',DATE_ADD(NOW(), INTERVAL 11 DAY),5,DATE_SUB(NOW(), INTERVAL 13 DAY),5,DATE_SUB(NOW(), INTERVAL 13 DAY),0),
(19,11,1,'官网留资后首次电话，客户希望一周内上线试用。','高意向',DATE_ADD(NOW(), INTERVAL 20 DAY),4,DATE_SUB(NOW(), INTERVAL 7 DAY),4,DATE_SUB(NOW(), INTERVAL 7 DAY),0),
(20,11,2,'微信发送试用账号与操作指南。','试用中',DATE_ADD(NOW(), INTERVAL 14 DAY),4,DATE_SUB(NOW(), INTERVAL 11 DAY),4,DATE_SUB(NOW(), INTERVAL 11 DAY),0),
(21,13,2,'微信沟通试点范围，先覆盖 20 人销售团队。','试点确认',DATE_ADD(NOW(), INTERVAL 4 DAY),5,DATE_SUB(NOW(), INTERVAL 8 DAY),5,DATE_SUB(NOW(), INTERVAL 8 DAY),0),
(22,13,4,'发送试点方案与验收标准。','待审批',DATE_ADD(NOW(), INTERVAL 10 DAY),5,DATE_SUB(NOW(), INTERVAL 16 DAY),5,DATE_SUB(NOW(), INTERVAL 16 DAY),0),
(23,14,3,'拜访集团营销中心，确认由总部统一选型。','决策链梳理',DATE_ADD(NOW(), INTERVAL 7 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(24,14,1,'电话沟通项目立项进度，预计下月进入招标。','等待立项',DATE_ADD(NOW(), INTERVAL 15 DAY),2,DATE_SUB(NOW(), INTERVAL 14 DAY),2,DATE_SUB(NOW(), INTERVAL 14 DAY),0),
(25,15,2,'微信沟通新店会员活动方案，客户预算约 3 万。','预算有限',DATE_ADD(NOW(), INTERVAL 8 DAY),5,DATE_SUB(NOW(), INTERVAL 12 DAY),5,DATE_SUB(NOW(), INTERVAL 12 DAY),0),
(26,16,3,'到校回访，确认续费与新增两个校区。','续费意向',DATE_ADD(NOW(), INTERVAL 30 DAY),4,DATE_SUB(NOW(), INTERVAL 5 DAY),4,DATE_SUB(NOW(), INTERVAL 5 DAY),0),
(27,16,1,'电话确认续费合同条款。','合同确认',DATE_ADD(NOW(), INTERVAL 20 DAY),4,DATE_SUB(NOW(), INTERVAL 19 DAY),4,DATE_SUB(NOW(), INTERVAL 19 DAY),0),
(28,17,1,'电话沟通 AI 客服场景，客户希望接入现有知识库。','需求明确',DATE_ADD(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(29,17,4,'发送方案评审材料与报价。','待评审',DATE_ADD(NOW(), INTERVAL 6 DAY),2,DATE_SUB(NOW(), INTERVAL 9 DAY),2,DATE_SUB(NOW(), INTERVAL 9 DAY),0),
(30,18,2,'微信沟通会员标签体系，客户关注复购分析。','需求确认',DATE_ADD(NOW(), INTERVAL 3 DAY),4,DATE_SUB(NOW(), INTERVAL 6 DAY),4,DATE_SUB(NOW(), INTERVAL 6 DAY),0),
(31,18,1,'电话演示标签分组功能。','演示完成',DATE_ADD(NOW(), INTERVAL 10 DAY),4,DATE_SUB(NOW(), INTERVAL 17 DAY),4,DATE_SUB(NOW(), INTERVAL 17 DAY),0),
(32,20,3,'上门沟通移动端体验要求，现场演示小程序。','体验认可',DATE_ADD(NOW(), INTERVAL 5 DAY),5,DATE_SUB(NOW(), INTERVAL 3 DAY),5,DATE_SUB(NOW(), INTERVAL 3 DAY),0),
(33,20,2,'微信发送报价与实施周期。','已报价',DATE_ADD(NOW(), INTERVAL 12 DAY),5,DATE_SUB(NOW(), INTERVAL 20 DAY),5,DATE_SUB(NOW(), INTERVAL 20 DAY),0),
(34,21,1,'集团采购部电话确认年度服务范围。','已签约',DATE_ADD(NOW(), INTERVAL 15 DAY),1,DATE_SUB(NOW(), INTERVAL 4 DAY),1,DATE_SUB(NOW(), INTERVAL 4 DAY),0),
(35,21,4,'发送年度服务报告。','客户满意',DATE_ADD(NOW(), INTERVAL 25 DAY),1,DATE_SUB(NOW(), INTERVAL 21 DAY),1,DATE_SUB(NOW(), INTERVAL 21 DAY),0),
(36,22,2,'微信了解社群规模，目前 12 个群约 5000 人。','待方案',DATE_ADD(NOW(), INTERVAL 9 DAY),4,DATE_SUB(NOW(), INTERVAL 14 DAY),4,DATE_SUB(NOW(), INTERVAL 14 DAY),0),
(37,23,3,'到店沟通多门店协同，客户有 18 家门店。','需求明确',DATE_ADD(NOW(), INTERVAL 6 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(38,23,1,'电话确认总部与门店权限划分。','方案调整',DATE_ADD(NOW(), INTERVAL 8 DAY),2,DATE_SUB(NOW(), INTERVAL 11 DAY),2,DATE_SUB(NOW(), INTERVAL 11 DAY),0),
(39,24,2,'微信跟进淡季预算审批进度。','等待审批',DATE_ADD(NOW(), INTERVAL 12 DAY),5,DATE_SUB(NOW(), INTERVAL 10 DAY),5,DATE_SUB(NOW(), INTERVAL 10 DAY),0),
(40,8,1,'公海线索首次外呼，未接通。','未接通',DATE_ADD(NOW(), INTERVAL 1 DAY),1,DATE_SUB(NOW(), INTERVAL 6 DAY),1,DATE_SUB(NOW(), INTERVAL 6 DAY),0),
(41,12,1,'公海线索外呼，客户表示暂无需求。','暂缓',DATE_ADD(NOW(), INTERVAL 30 DAY),1,DATE_SUB(NOW(), INTERVAL 8 DAY),1,DATE_SUB(NOW(), INTERVAL 8 DAY),0),
(42,19,2,'微信添加好友未通过。','待触达',DATE_ADD(NOW(), INTERVAL 3 DAY),1,DATE_SUB(NOW(), INTERVAL 11 DAY),1,DATE_SUB(NOW(), INTERVAL 11 DAY),0),
(43,1,2,'微信发送合同草稿，等待法务确认。','合同审核',DATE_ADD(NOW(), INTERVAL 3 DAY),2,DATE_SUB(NOW(), INTERVAL 2 HOUR),2,DATE_SUB(NOW(), INTERVAL 2 HOUR),0),
(44,4,1,'电话确认最终报价折扣。','商务谈判',DATE_ADD(NOW(), INTERVAL 4 DAY),2,DATE_SUB(NOW(), INTERVAL 5 HOUR),2,DATE_SUB(NOW(), INTERVAL 5 HOUR),0),
(45,9,4,'邮件发送年度合作方案。','待反馈',DATE_ADD(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 8 HOUR),2,DATE_SUB(NOW(), INTERVAL 8 HOUR),0),
(46,11,2,'微信沟通试用反馈，客户满意度较高。','准备签约',DATE_ADD(NOW(), INTERVAL 3 DAY),4,DATE_SUB(NOW(), INTERVAL 1 DAY),4,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(47,17,1,'电话确认评审会时间。','评审排期',DATE_ADD(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 3 HOUR),2,DATE_SUB(NOW(), INTERVAL 3 HOUR),0),
(48,23,4,'邮件发送多门店权限方案。','待确认',DATE_ADD(NOW(), INTERVAL 6 DAY),2,DATE_SUB(NOW(), INTERVAL 6 HOUR),2,DATE_SUB(NOW(), INTERVAL 6 HOUR),0);

INSERT INTO `biz_opportunity` (`id`,`customer_id`,`name`,`amount`,`stage`,`probability`,`expected_close_date`,`owner_id`,`remark`,`create_by`,`create_time`,`update_by`,`update_time`,`is_deleted`) VALUES
(1,1,'海川科技年度 SCRM 采购',180000.00,4,80,DATE_ADD(CURDATE(), INTERVAL 15 DAY),2,'合同条款审核中',2,DATE_SUB(NOW(), INTERVAL 60 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(2,4,'极客网络 API 集成项目',96000.00,3,60,DATE_ADD(CURDATE(), INTERVAL 25 DAY),2,'等待最终报价',2,DATE_SUB(NOW(), INTERVAL 40 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(3,6,'云启软件二期扩容',60000.00,5,100,DATE_SUB(CURDATE(), INTERVAL 10 DAY),1,'已赢单',1,DATE_SUB(NOW(), INTERVAL 55 DAY),1,DATE_SUB(NOW(), INTERVAL 10 DAY),0),
(4,9,'花间集私域会员运营',128000.00,3,65,DATE_ADD(CURDATE(), INTERVAL 20 DAY),2,'标签体系方案已确认',2,DATE_SUB(NOW(), INTERVAL 30 DAY),2,DATE_SUB(NOW(), INTERVAL 3 DAY),0),
(5,11,'优品电商试用转正式',72000.00,4,85,DATE_ADD(CURDATE(), INTERVAL 10 DAY),4,'试用反馈良好',4,DATE_SUB(NOW(), INTERVAL 20 DAY),4,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(6,14,'华宇地产集团会员平台',350000.00,2,40,DATE_ADD(CURDATE(), INTERVAL 60 DAY),2,'等待集团立项',2,DATE_SUB(NOW(), INTERVAL 25 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(7,16,'卓越教育续费及校区扩展',48000.00,5,100,DATE_SUB(CURDATE(), INTERVAL 5 DAY),4,'已赢单',4,DATE_SUB(NOW(), INTERVAL 40 DAY),4,DATE_SUB(NOW(), INTERVAL 5 DAY),0),
(8,17,'峰云智能 AI 客服接入',156000.00,3,60,DATE_ADD(CURDATE(), INTERVAL 18 DAY),2,'方案评审中',2,DATE_SUB(NOW(), INTERVAL 18 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(9,21,'天翼通信年度服务续约',240000.00,5,100,DATE_SUB(CURDATE(), INTERVAL 12 DAY),1,'已赢单',1,DATE_SUB(NOW(), INTERVAL 50 DAY),1,DATE_SUB(NOW(), INTERVAL 12 DAY),0),
(10,10,'远景新能源供应商选型',88000.00,2,35,DATE_ADD(CURDATE(), INTERVAL 35 DAY),5,'与两家竞品对比中',5,DATE_SUB(NOW(), INTERVAL 22 DAY),5,DATE_SUB(NOW(), INTERVAL 6 DAY),0),
(11,23,'风行汽车多门店协同',110000.00,3,55,DATE_ADD(CURDATE(), INTERVAL 28 DAY),2,'权限方案待确认',2,DATE_SUB(NOW(), INTERVAL 15 DAY),2,DATE_SUB(NOW(), INTERVAL 6 HOUR),0),
(12,20,'宜家装饰移动端升级',56000.00,2,40,DATE_ADD(CURDATE(), INTERVAL 40 DAY),5,'报价已发',5,DATE_SUB(NOW(), INTERVAL 12 DAY),5,DATE_SUB(NOW(), INTERVAL 3 DAY),0),
(13,7,'康泰医疗本地化部署',168000.00,1,20,DATE_ADD(CURDATE(), INTERVAL 75 DAY),4,'合规评估阶段',4,DATE_SUB(NOW(), INTERVAL 10 DAY),4,DATE_SUB(NOW(), INTERVAL 4 DAY),0),
(14,2,'星辰传媒内容营销合作',36000.00,6,0,DATE_SUB(CURDATE(), INTERVAL 3 DAY),4,'客户选择竞品',4,DATE_SUB(NOW(), INTERVAL 16 DAY),4,DATE_SUB(NOW(), INTERVAL 3 DAY),0);

INSERT INTO `biz_contract` (`id`,`contract_no`,`customer_id`,`opportunity_id`,`name`,`amount`,`sign_date`,`start_date`,`end_date`,`status`,`owner_id`,`remark`,`create_by`,`create_time`,`update_by`,`update_time`,`is_deleted`) VALUES
(1,'HT2025-0001',6,3,'云启软件 SCRM 年度服务合同',98000.00,DATE_SUB(CURDATE(), INTERVAL 100 DAY),DATE_SUB(CURDATE(), INTERVAL 95 DAY),DATE_ADD(CURDATE(), INTERVAL 270 DAY),2,1,'二期扩容另行签署',1,DATE_SUB(NOW(), INTERVAL 100 DAY),1,DATE_SUB(NOW(), INTERVAL 10 DAY),0),
(2,'HT2025-0002',16,7,'卓越教育会员系统续费合同',48000.00,DATE_SUB(CURDATE(), INTERVAL 8 DAY),DATE_SUB(CURDATE(), INTERVAL 5 DAY),DATE_ADD(CURDATE(), INTERVAL 360 DAY),2,4,'含两个新增校区',4,DATE_SUB(NOW(), INTERVAL 8 DAY),4,DATE_SUB(NOW(), INTERVAL 5 DAY),0),
(3,'HT2025-0003',21,9,'天翼通信年度客户运营服务合同',240000.00,DATE_SUB(CURDATE(), INTERVAL 15 DAY),DATE_SUB(CURDATE(), INTERVAL 12 DAY),DATE_ADD(CURDATE(), INTERVAL 353 DAY),2,1,'年度框架合同',1,DATE_SUB(NOW(), INTERVAL 15 DAY),1,DATE_SUB(NOW(), INTERVAL 12 DAY),0),
(4,'HT2024-0012',11,NULL,'优品电商会员服务合同',36000.00,DATE_SUB(CURDATE(), INTERVAL 200 DAY),DATE_SUB(CURDATE(), INTERVAL 195 DAY),DATE_SUB(CURDATE(), INTERVAL 15 DAY),3,4,'已完成验收',4,DATE_SUB(NOW(), INTERVAL 200 DAY),4,DATE_SUB(NOW(), INTERVAL 15 DAY),0),
(5,'HT2024-0015',1,NULL,'海川科技试点服务合同',28000.00,DATE_SUB(CURDATE(), INTERVAL 150 DAY),DATE_SUB(CURDATE(), INTERVAL 145 DAY),DATE_SUB(CURDATE(), INTERVAL 20 DAY),3,2,'试点验收通过',2,DATE_SUB(NOW(), INTERVAL 150 DAY),2,DATE_SUB(NOW(), INTERVAL 20 DAY),0),
(6,'HT2025-0004',23,NULL,'风行汽车门店协同服务合同',68000.00,DATE_SUB(CURDATE(), INTERVAL 2 DAY),DATE_ADD(CURDATE(), INTERVAL 5 DAY),DATE_ADD(CURDATE(), INTERVAL 370 DAY),1,2,'草稿待盖章',2,DATE_SUB(NOW(), INTERVAL 2 DAY),2,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(7,'HT2024-0008',7,NULL,'康泰医疗数据服务合同',42000.00,DATE_SUB(CURDATE(), INTERVAL 300 DAY),DATE_SUB(CURDATE(), INTERVAL 290 DAY),DATE_SUB(CURDATE(), INTERVAL 30 DAY),4,4,'客户提前终止',4,DATE_SUB(NOW(), INTERVAL 300 DAY),4,DATE_SUB(NOW(), INTERVAL 30 DAY),0),
(8,'HT2025-0005',9,NULL,'花间集会员运营试点合同',30000.00,DATE_SUB(CURDATE(), INTERVAL 6 DAY),DATE_SUB(CURDATE(), INTERVAL 3 DAY),DATE_ADD(CURDATE(), INTERVAL 87 DAY),2,2,'试点三个月',2,DATE_SUB(NOW(), INTERVAL 6 DAY),2,DATE_SUB(NOW(), INTERVAL 3 DAY),0);

INSERT INTO `biz_campaign` (`id`,`name`,`type`,`channel`,`budget`,`start_date`,`end_date`,`status`,`target_count`,`lead_count`,`owner_id`,`remark`,`create_by`,`create_time`,`update_by`,`update_time`,`is_deleted`) VALUES
(1,'2025 夏季私域增长峰会',2,'线下会议',50000.00,DATE_SUB(CURDATE(), INTERVAL 45 DAY),DATE_SUB(CURDATE(), INTERVAL 40 DAY),2,200,236,1,'线索转化率 18%',1,DATE_SUB(NOW(), INTERVAL 70 DAY),1,DATE_SUB(NOW(), INTERVAL 40 DAY),0),
(2,'SCRM 免费试用直播课',1,'视频号直播',12000.00,DATE_SUB(CURDATE(), INTERVAL 20 DAY),DATE_SUB(CURDATE(), INTERVAL 20 DAY),2,500,682,2,'回放持续获客',2,DATE_SUB(NOW(), INTERVAL 30 DAY),2,DATE_SUB(NOW(), INTERVAL 20 DAY),0),
(3,'百度 SEM 品牌词投放',3,'百度推广',80000.00,DATE_SUB(CURDATE(), INTERVAL 12 DAY),DATE_ADD(CURDATE(), INTERVAL 18 DAY),1,300,154,2,'线索成本 128 元',2,DATE_SUB(NOW(), INTERVAL 12 DAY),2,DATE_SUB(NOW(), INTERVAL 1 DAY),0),
(4,'客户成功案例拆解专栏',4,'公众号',8000.00,DATE_SUB(CURDATE(), INTERVAL 60 DAY),DATE_ADD(CURDATE(), INTERVAL 30 DAY),1,150,97,4,'每周一篇',4,DATE_SUB(NOW(), INTERVAL 60 DAY),4,DATE_SUB(NOW(), INTERVAL 2 DAY),0),
(5,'秋季行业客户答谢会',2,'线下晚宴',120000.00,DATE_ADD(CURDATE(), INTERVAL 30 DAY),DATE_ADD(CURDATE(), INTERVAL 30 DAY),0,100,0,1,'筹备中',1,DATE_SUB(NOW(), INTERVAL 5 DAY),1,DATE_SUB(NOW(), INTERVAL 5 DAY),0);

-- =============================================================
-- 菜单与权限
-- =============================================================
-- 隐藏演示菜单，保留系统管理
UPDATE `sys_menu` SET `visible` = 0 WHERE `id` IN (2,4,5,6,7,8,9);

INSERT INTO `sys_menu` (`id`,`parent_id`,`tree_path`,`name`,`type`,`route_name`,`route_path`,`component`,`perm`,`always_show`,`keep_alive`,`visible`,`sort`,`icon`,`redirect`,`create_time`,`update_time`,`params`) VALUES
(1000,0,'0','客户管理','C','','/customer','Layout',NULL,0,0,1,1,'el-icon-User','/customer/list',NOW(),NOW(),NULL),
(1010,1000,'0,1000','客户列表','M','Customer','list','customer/index',NULL,0,1,1,1,'el-icon-User',NULL,NOW(),NOW(),NULL),
(1011,1010,'0,1000,1010','客户查询','B',NULL,'','', 'scrm:customer:list',0,0,1,1,'',NULL,NOW(),NOW(),NULL),
(1012,1010,'0,1000,1010','客户新增','B',NULL,'','', 'scrm:customer:create',0,0,1,2,'',NULL,NOW(),NOW(),NULL),
(1013,1010,'0,1000,1010','客户编辑','B',NULL,'','', 'scrm:customer:update',0,0,1,3,'',NULL,NOW(),NOW(),NULL),
(1014,1010,'0,1000,1010','客户删除','B',NULL,'','', 'scrm:customer:delete',0,0,1,4,'',NULL,NOW(),NOW(),NULL),
(1015,1010,'0,1000,1010','客户分配','B',NULL,'','', 'scrm:customer:assign',0,0,1,5,'',NULL,NOW(),NOW(),NULL),
(1016,1010,'0,1000,1010','客户导出','B',NULL,'','', 'scrm:customer:export',0,0,1,6,'',NULL,NOW(),NOW(),NULL),
(1020,1000,'0,1000','客户公海','M','CustomerPool','pool','customer/pool',NULL,0,1,1,2,'el-icon-Box',NULL,NOW(),NOW(),NULL),
(1021,1020,'0,1000,1020','领取客户','B',NULL,'','', 'scrm:customer:claim',0,0,1,1,'',NULL,NOW(),NOW(),NULL),
(1030,1000,'0,1000','标签管理','M','CustomerTag','tag','customer/tag/index',NULL,0,1,1,3,'el-icon-CollectionTag',NULL,NOW(),NOW(),NULL),
(1031,1030,'0,1000,1030','标签查询','B',NULL,'','', 'scrm:tag:list',0,0,1,1,'',NULL,NOW(),NOW(),NULL),
(1032,1030,'0,1000,1030','标签新增','B',NULL,'','', 'scrm:tag:create',0,0,1,2,'',NULL,NOW(),NOW(),NULL),
(1033,1030,'0,1000,1030','标签编辑','B',NULL,'','', 'scrm:tag:update',0,0,1,3,'',NULL,NOW(),NOW(),NULL),
(1034,1030,'0,1000,1030','标签删除','B',NULL,'','', 'scrm:tag:delete',0,0,1,4,'',NULL,NOW(),NOW(),NULL),
(2000,0,'0','销售管理','C','','/sales','Layout',NULL,0,0,1,2,'el-icon-Money','/sales/opportunity',NOW(),NOW(),NULL),
(2010,2000,'0,2000','跟进记录','M','FollowUp','follow-up','sales/follow-up/index',NULL,0,1,1,1,'el-icon-ChatDotRound',NULL,NOW(),NOW(),NULL),
(2011,2010,'0,2000,2010','跟进查询','B',NULL,'','', 'scrm:follow-up:list',0,0,1,1,'',NULL,NOW(),NOW(),NULL),
(2012,2010,'0,2000,2010','跟进新增','B',NULL,'','', 'scrm:follow-up:create',0,0,1,2,'',NULL,NOW(),NOW(),NULL),
(2013,2010,'0,2000,2010','跟进编辑','B',NULL,'','', 'scrm:follow-up:update',0,0,1,3,'',NULL,NOW(),NOW(),NULL),
(2014,2010,'0,2000,2010','跟进删除','B',NULL,'','', 'scrm:follow-up:delete',0,0,1,4,'',NULL,NOW(),NOW(),NULL),
(2020,2000,'0,2000','商机管理','M','Opportunity','opportunity','sales/opportunity/index',NULL,0,1,1,2,'el-icon-TrendCharts',NULL,NOW(),NOW(),NULL),
(2021,2020,'0,2000,2020','商机查询','B',NULL,'','', 'scrm:opportunity:list',0,0,1,1,'',NULL,NOW(),NOW(),NULL),
(2022,2020,'0,2000,2020','商机新增','B',NULL,'','', 'scrm:opportunity:create',0,0,1,2,'',NULL,NOW(),NOW(),NULL),
(2023,2020,'0,2000,2020','商机编辑','B',NULL,'','', 'scrm:opportunity:update',0,0,1,3,'',NULL,NOW(),NOW(),NULL),
(2024,2020,'0,2000,2020','商机删除','B',NULL,'','', 'scrm:opportunity:delete',0,0,1,4,'',NULL,NOW(),NOW(),NULL),
(2030,2000,'0,2000','合同管理','M','Contract','contract','sales/contract/index',NULL,0,1,1,3,'el-icon-Document',NULL,NOW(),NOW(),NULL),
(2031,2030,'0,2000,2030','合同查询','B',NULL,'','', 'scrm:contract:list',0,0,1,1,'',NULL,NOW(),NOW(),NULL),
(2032,2030,'0,2000,2030','合同新增','B',NULL,'','', 'scrm:contract:create',0,0,1,2,'',NULL,NOW(),NOW(),NULL),
(2033,2030,'0,2000,2030','合同编辑','B',NULL,'','', 'scrm:contract:update',0,0,1,3,'',NULL,NOW(),NOW(),NULL),
(2034,2030,'0,2000,2030','合同删除','B',NULL,'','', 'scrm:contract:delete',0,0,1,4,'',NULL,NOW(),NOW(),NULL),
(3000,0,'0','营销管理','C','','/marketing','Layout',NULL,0,0,1,3,'el-icon-Promotion','/marketing/campaign',NOW(),NOW(),NULL),
(3010,3000,'0,3000','活动管理','M','Campaign','campaign','marketing/campaign/index',NULL,0,1,1,1,'el-icon-Tickets',NULL,NOW(),NOW(),NULL),
(3011,3010,'0,3000,3010','活动查询','B',NULL,'','', 'scrm:campaign:list',0,0,1,1,'',NULL,NOW(),NOW(),NULL),
(3012,3010,'0,3000,3010','活动新增','B',NULL,'','', 'scrm:campaign:create',0,0,1,2,'',NULL,NOW(),NOW(),NULL),
(3013,3010,'0,3000,3010','活动编辑','B',NULL,'','', 'scrm:campaign:update',0,0,1,3,'',NULL,NOW(),NOW(),NULL),
(3014,3010,'0,3000,3010','活动删除','B',NULL,'','', 'scrm:campaign:delete',0,0,1,4,'',NULL,NOW(),NOW(),NULL)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `update_time` = NOW();

-- 管理员角色授予 SCRM 菜单
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) VALUES
(2,1000),(2,1010),(2,1011),(2,1012),(2,1013),(2,1014),(2,1015),(2,1016),
(2,1020),(2,1021),(2,1030),(2,1031),(2,1032),(2,1033),(2,1034),
(2,2000),(2,2010),(2,2011),(2,2012),(2,2013),(2,2014),
(2,2020),(2,2021),(2,2022),(2,2023),(2,2024),
(2,2030),(2,2031),(2,2032),(2,2033),(2,2034),
(2,3000),(2,3010),(2,3011),(2,3012),(2,3013),(2,3014);

SET FOREIGN_KEY_CHECKS = 1;

-- 部门经理 / 部门成员 / 员工默认授予 SCRM 菜单与操作权限
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) VALUES
(4,1000),(4,1010),(4,1011),(4,1012),(4,1013),(4,1014),(4,1015),(4,1016),(4,1020),(4,1021),(4,1030),(4,1031),(4,1032),(4,1033),(4,1034),
(4,2000),(4,2010),(4,2011),(4,2012),(4,2013),(4,2014),(4,2020),(4,2021),(4,2022),(4,2023),(4,2024),(4,2030),(4,2031),(4,2032),(4,2033),(4,2034),
(4,3000),(4,3010),(4,3011),(4,3012),(4,3013),(4,3014),
(5,1000),(5,1010),(5,1011),(5,1012),(5,1013),(5,1014),(5,1020),(5,1021),(5,1030),(5,1031),
(5,2000),(5,2010),(5,2011),(5,2012),(5,2013),(5,2014),(5,2020),(5,2021),(5,2022),(5,2023),(5,2024),(5,2030),(5,2031),(5,2032),(5,2033),(5,2034),
(5,3000),(5,3010),(5,3011),(5,3012),(5,3013),(5,3014),
(6,1000),(6,1010),(6,1011),(6,1012),(6,1013),(6,1014),(6,1020),(6,1021),(6,1030),(6,1031),
(6,2000),(6,2010),(6,2011),(6,2012),(6,2013),(6,2014),(6,2020),(6,2021),(6,2022),(6,2023),(6,2024),(6,2030),(6,2031),(6,2032),(6,2033),(6,2034),
(6,3000),(6,3010),(6,3011),(6,3012),(6,3013),(6,3014);
