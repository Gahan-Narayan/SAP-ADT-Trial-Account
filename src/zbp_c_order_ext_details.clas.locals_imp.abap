CLASS lhc_OrderExtDetails DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_ext_buffer,
             order_id TYPE zorder_ext-order_id,
             priority TYPE zorder_ext-priority,
             remarks  TYPE zorder_ext-remarks,
             is_new   TYPE abap_bool,
           END OF ty_ext_buffer.

    CLASS-DATA: mt_ext_buffer TYPE TABLE OF ty_ext_buffer.

  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR OrderExtDetails RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE OrderExtDetails.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE OrderExtDetails.

    METHODS read FOR READ
      IMPORTING keys FOR READ OrderExtDetails RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK OrderExtDetails.

ENDCLASS.

CLASS lhc_OrderExtDetails IMPLEMENTATION.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(entity).

      MODIFY ENTITIES OF ZR_ORDER_TAB
        ENTITY OrderTable
        CREATE FIELDS ( Description Status )
        WITH VALUE #( ( %cid        = entity-%cid
                         Description = entity-Description
                         Status      = entity-Status ) )
        MAPPED   DATA(ls_mapped)
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).

      IF ls_mapped-ordertable IS NOT INITIAL.
        DATA(lv_new_id) = ls_mapped-ordertable[ 1 ]-OrderID.

        APPEND VALUE #( order_id = lv_new_id
                         priority = entity-Priority
                         remarks  = entity-Remarks
                         is_new   = abap_true )
               TO mt_ext_buffer.

        mapped-orderextdetails = VALUE #( ( %cid    = entity-%cid
                                             OrderID = lv_new_id ) ).
      ELSE.
        APPEND VALUE #( %cid = entity-%cid ) TO failed-orderextdetails.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(entity).

      MODIFY ENTITIES OF ZR_ORDER_TAB
        ENTITY OrderTable
        UPDATE FIELDS ( Description Status )
        WITH VALUE #( ( %key        = VALUE #( OrderID = entity-OrderID )
                         Description = entity-Description
                         Status      = entity-Status ) )
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).

      APPEND VALUE #( order_id = entity-OrderID
                       priority = entity-Priority
                       remarks  = entity-Remarks
                       is_new   = abap_false )
             TO mt_ext_buffer.

    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT o~order_id, o~description, o~status,
           o~created_by, o~created_at, o~last_changed_by, o~changed_at,
           e~priority, e~remarks
      FROM zorder_tab AS o
      LEFT OUTER JOIN zorder_ext AS e
        ON o~order_id = e~order_id
      FOR ALL ENTRIES IN @keys
      WHERE o~order_id = @keys-OrderID
      INTO TABLE @DATA(lt_db).

    result = VALUE #( FOR db IN lt_db
      ( %tky          = VALUE #( OrderID = db-order_id )
        Description   = db-description
        Status        = db-status
        CreatedBy     = db-created_by
        CreatedAt     = db-created_at
        LastChangedBy = db-last_changed_by
        ChangedAt     = db-changed_at
        Priority      = db-priority
        Remarks       = db-remarks ) ).
  ENDMETHOD.

  METHOD lock.
    " Concurrency for the header is protected by ZR_ORDER_TAB's own
    " lock, invoked via EML in create/update above.
  ENDMETHOD.

ENDCLASS.


CLASS lsc_ZC_ORDER_EXT_DETAILS DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZC_ORDER_EXT_DETAILS IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    LOOP AT lhc_OrderExtDetails=>mt_ext_buffer INTO DATA(buf) WHERE is_new = abap_true.
      INSERT zorder_ext FROM @( VALUE #(
        order_id = buf-order_id
        priority = buf-priority
        remarks  = buf-remarks ) ).
    ENDLOOP.

    LOOP AT lhc_OrderExtDetails=>mt_ext_buffer INTO buf WHERE is_new = abap_false.
      UPDATE zorder_ext SET
        priority = @buf-priority,
        remarks  = @buf-remarks
        WHERE order_id = @buf-order_id.
    ENDLOOP.

    CLEAR lhc_OrderExtDetails=>mt_ext_buffer.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR lhc_OrderExtDetails=>mt_ext_buffer.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

