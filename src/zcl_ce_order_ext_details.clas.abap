CLASS zcl_ce_order_ext_details DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

ENDCLASS.

CLASS zcl_ce_order_ext_details IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    DATA: lt_result TYPE STANDARD TABLE OF zc_order_ext_details.

    " Range table for OrderID filtering (extend with more fields as needed)
    DATA: ra_order_id TYPE RANGE OF zorder_tab-order_id.

    TRY.
        IF io_request->is_data_requested( ).

          " ---- Filter handling ----
          TRY.
              DATA(lt_filters) = io_request->get_filter( )->get_as_ranges( ).
            CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
              DATA(exception_message) =
                cl_message_helper=>get_latest_t100_exception( lx_no_sel_option )->if_message~get_longtext( ).
          ENDTRY.

          LOOP AT lt_filters INTO DATA(ls_filter).
            CASE ls_filter-name.
              WHEN 'ORDERID'.
                ra_order_id = CORRESPONDING #( ls_filter-range ).
            ENDCASE.
          ENDLOOP.

          " ---- Data selection (join, with optional filter applied) ----
          SELECT o~order_id, o~description, o~status,
                 o~created_by, o~created_at, o~last_changed_by, o~changed_at,
                 e~priority, e~remarks
            FROM zorder_tab AS o
            LEFT OUTER JOIN zorder_ext AS e
              ON o~order_id = e~order_id
            WHERE o~order_id IN @ra_order_id
            INTO TABLE @lt_result.

          " ---- Paging ----
          DATA(lo_paging)    = io_request->get_paging( ).
          DATA(lv_page_size) = lo_paging->get_page_size( ).
          DATA(lv_offset)    = lo_paging->get_offset( ).

          DATA(lt_paged_result) = lt_result.

          IF lv_page_size <> if_rap_query_paging=>page_size_unlimited.
            CLEAR lt_paged_result.
            LOOP AT lt_result INTO DATA(ls_paged) FROM lv_offset + 1 TO lv_offset + lv_page_size.
              APPEND ls_paged TO lt_paged_result.
            ENDLOOP.
          ENDIF.

          io_response->set_total_number_of_records( lines( lt_result ) ).
          io_response->set_data( lt_paged_result ).

        ENDIF.

      CATCH cx_rap_query_provider INTO DATA(lx_exc).
        exception_message = cl_message_helper=>get_latest_t100_exception( lx_exc )->if_message~get_longtext( ).
        RAISE EXCEPTION lx_exc.

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
