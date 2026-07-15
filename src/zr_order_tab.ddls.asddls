@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZORDER_TAB'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_ORDER_TAB
  as select from ZORDER_TAB as OrderTable
{
  key order_id as OrderID,
  description as Description,
  status as Status,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  changed_at as ChangedAt
}
