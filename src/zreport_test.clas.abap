CLASS zreport_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA lv_url TYPE string.
    INTERFACES if_oo_adt_classrun.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.

    METHODS call_post
      IMPORTING
        iv_url         TYPE string OPTIONAL
        iv_destination TYPE string OPTIONAL
        iv_payload     TYPE string
      EXPORTING
        ev_status      TYPE i
        ev_response    TYPE string
        ev_message     TYPE string.

    METHODS run_test
      IMPORTING
        iv_url         TYPE string OPTIONAL
        iv_destination TYPE string OPTIONAL
        io_out         TYPE REF TO if_oo_adt_classrun_out OPTIONAL.

ENDCLASS.


CLASS zreport_test  IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    run_test(
      iv_url = 'https://webhook.site/3225de9a-8ccf-4f29-9774-567b356fc37c'
      io_out = out ).
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Declares which parameters the job scheduling UI should expose.
    " Matching the sample: one string parameter for the target URL.
    et_parameter_def = VALUE #(
      ( selname    = 'IV_URL'
        kind       = if_apj_dt_exec_object=>parameter
        datatype   = 'STRG'
        length     = 0
        param_text = 'Target URL' )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    " it_parameter holds runtime values passed in from the scheduled job,
    " matching the selname values declared in get_parameters.
    lv_url = 'https://webhook.site/3225de9a-8ccf-4f29-9774-567b356fc37c'.

    LOOP AT it_parameters INTO DATA(ls_param).
      IF ls_param-selname = 'IV_URL'.
        lv_url = ls_param-low.
      ENDIF.
    ENDLOOP.

    run_test( iv_url = lv_url ).
  ENDMETHOD.


  METHOD call_post.

    DATA: lo_destination TYPE REF TO if_http_destination,
          lo_http_client TYPE REF TO if_web_http_client,
          lo_request     TYPE REF TO if_web_http_request,
          lo_response    TYPE REF TO if_web_http_response.

    CLEAR: ev_status, ev_response, ev_message.

    TRY.
        IF iv_url IS NOT INITIAL.
          lo_destination = cl_http_destination_provider=>create_by_url( iv_url ).
        ELSE.
          ev_message = 'No iv_url supplied'.
          RETURN.
        ENDIF.

        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        lo_request = lo_http_client->get_http_request( ).
        lo_request->set_text( iv_payload ).
        lo_request->set_content_type( 'application/json' ).

        lo_response = lo_http_client->execute( if_web_http_client=>post ).

        ev_status   = lo_response->get_status( )-code.
        ev_response = lo_response->get_text( ).

        IF ev_status < 200 OR ev_status > 299.
          ev_message = |Non-2xx status: { ev_status }|.
        ENDIF.

      CATCH cx_root INTO DATA(lx_error).
        ev_message = lx_error->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD run_test.

    DATA: lt_access   TYPE TABLE OF zr_tab_ca_inv_acc,
          lv_payload  TYPE string,
          lv_status   TYPE i,
          lv_response TYPE string,
          lv_message  TYPE string.

    SELECT FROM zr_tab_ca_inv_acc
      FIELDS userid, AccessFlag, CreatedBy, CreatedAt, LastChangedBy, ChangedAt
      INTO TABLE @lt_access
      UP TO 10 ROWS.

    IF lt_access IS INITIAL.
      IF io_out IS BOUND.
        io_out->write( 'No data found in ZR_TAB_CA_INV_ACC' ).
      ENDIF.
      RETURN.
    ENDIF.

    lv_payload = /ui2/cl_json=>serialize(
                   data        = lt_access
                   compress    = abap_true
                   pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    call_post(
      EXPORTING
        iv_url         = iv_url
        iv_destination = iv_destination
        iv_payload     = lv_payload
      IMPORTING
        ev_status      = lv_status
        ev_response    = lv_response
        ev_message     = lv_message ).

    IF io_out IS BOUND.
      io_out->write( |Rows fetched: { lines( lt_access ) }| ).
      io_out->write( |Payload sent: { lv_payload }| ).
      io_out->write( |Status: { lv_status }| ).
      io_out->write( |Response: { lv_response }| ).
      io_out->write( |Message: { lv_message }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
