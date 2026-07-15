CLASS lhc_OrderTable DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    CLASS-DATA: mt_create TYPE TABLE FOR CREATE zr_order_tab,
                mt_update TYPE TABLE FOR UPDATE zr_order_tab,
                mt_delete TYPE TABLE FOR DELETE zr_order_tab.

  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR OrderTable RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE OrderTable.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE OrderTable.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE OrderTable.

    METHODS read FOR READ
      IMPORTING keys FOR READ OrderTable RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK OrderTable.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR OrderTable RESULT result.

ENDCLASS.

CLASS lhc_OrderTable IMPLEMENTATION.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR key IN keys
      ( %tky                   = key-%tky
        %features-%action-Edit = if_abap_behv=>fc-o-enabled ) ).
  ENDMETHOD.

  METHOD lock.
    " Draft framework handles concurrency via draft_uuid ownership;
    " explicit ENQUEUE not required for this demo.
  ENDMETHOD.

  METHOD read.
    " Draft table uses NO-underscore column names.
    SELECT order_id, description, status,
           created_by,
           created_at,
           last_changed_by,
           changed_at
      FROM zorder_tab
      FOR ALL ENTRIES IN @keys
      WHERE order_id = @keys-OrderID
      INTO TABLE @DATA(lt_db).

    result = VALUE #( FOR db IN lt_db
      ( %tky          = VALUE #( OrderID = db-order_id )
        Description   = db-description
        Status        = db-status
        CreatedBy     = db-created_by
        CreatedAt     = db-created_at
        LastChangedBy = db-last_changed_by
        ChangedAt     = db-changed_at ) ).
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(entity).

      TRY.
          DATA(lv_id) = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_uuid_error INTO DATA(lx_uuid).
          APPEND VALUE #( %cid = entity-%cid ) TO failed-ordertable.
          CONTINUE.
      ENDTRY.

      entity-OrderID = lv_id.
      APPEND entity TO mt_create.

      mapped-ordertable = VALUE #( ( %cid      = entity-%cid
                                      %is_draft = abap_true
                                      OrderID   = lv_id ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    mt_update = CORRESPONDING #( entities ).
  ENDMETHOD.

  METHOD delete.
    mt_delete = CORRESPONDING #( keys ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_ORDER_TAB DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_ORDER_TAB IMPLEMENTATION.

  METHOD finalize.
    " Derive/complete field values before consistency checks run.
    " No-op for this demo.
  ENDMETHOD.

  METHOD check_before_save.
    " Cross-entity validation before commit. No-op for this demo.
  ENDMETHOD.

  METHOD save.

    DATA(lv_tzntstmpl) = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).

    LOOP AT lhc_OrderTable=>mt_create INTO DATA(create_entity).
      INSERT zorder_tab FROM @( VALUE #(
        order_id       = create_entity-OrderID
        description   = create_entity-Description
        status        = create_entity-Status
        created_by     = sy-uname
        created_at     = lv_tzntstmpl
        last_changed_by = sy-uname
        changed_at     = lv_tzntstmpl ) ).
    ENDLOOP.

    LOOP AT lhc_OrderTable=>mt_update INTO DATA(update_entity).
      UPDATE zorder_tab SET
        description   = @update_entity-Description,
        status        = @update_entity-Status,
        last_changed_by = @sy-uname,
        changed_at     = @lv_tzntstmpl
        WHERE order_id = @update_entity-OrderID.
    ENDLOOP.

    LOOP AT lhc_OrderTable=>mt_delete INTO DATA(delete_key).
      DELETE FROM zorder_tab_d WHERE orderid = @delete_key-OrderID.
    ENDLOOP.

    CLEAR: lhc_OrderTable=>mt_create,
           lhc_OrderTable=>mt_update,
           lhc_OrderTable=>mt_delete.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lhc_OrderTable=>mt_create,
           lhc_OrderTable=>mt_update,
           lhc_OrderTable=>mt_delete.
  ENDMETHOD.

  METHOD cleanup_finalize.
    " Cleanup counterpart for the finalize phase. No-op here.
  ENDMETHOD.

ENDCLASS.
