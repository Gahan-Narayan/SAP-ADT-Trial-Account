@EndUserText.label: 'Order Details - Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CE_ORDER_EXT_DETAILS'
define root custom entity ZC_ORDER_EXT_DETAILS
{
  key OrderID       : abap.char(32);
      Description   : abap.char(40);
      Status        : abap.char(2);
      CreatedBy     : abp_creation_user;
      CreatedAt     : abp_creation_tstmpl;
      LastChangedBy : abp_lastchange_user;
      ChangedAt     : abp_lastchange_tstmpl;
      Priority      : abap.char(1);
      Remarks       : abap.char(100);
}
