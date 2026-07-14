@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTAB_CA_INV_ACC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TAB_CA_INV_ACC
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TAB_CA_INV_ACC
  association [1..1] to ZR_TAB_CA_INV_ACC as _BaseEntity on $projection.USERID = _BaseEntity.USERID
{
  key Userid,
  AccessFlag,
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
