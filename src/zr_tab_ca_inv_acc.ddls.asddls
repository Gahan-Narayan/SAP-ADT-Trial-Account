@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTAB_CA_INV_ACC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TAB_CA_INV_ACC
  as select from ZTAB_CA_INV_ACC
{
  key userid as Userid,
  access_flag as AccessFlag,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  changed_at as ChangedAt
}
