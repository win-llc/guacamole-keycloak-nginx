insert into guacamole_entity (entity_id,name,type) values (500, 'Domain Admins', 'USER_GROUP');
insert into guacamole_user_group(user_group_id,entity_id,disabled) values (500,500,false);
insert into guacamole_system_permission(entity_id,permission) values (500,'ADMINISTER');
