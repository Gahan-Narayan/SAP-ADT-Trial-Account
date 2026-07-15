@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZORDER_TAB'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_ORDER_TAB
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_ORDER_TAB
  association [1..1] to ZR_ORDER_TAB as _BaseEntity on $projection.ORDERID = _BaseEntity.ORDERID
{
  key OrderID,
  Description,
  Status,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Lastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  ChangedAt,
  _BaseEntity
}
