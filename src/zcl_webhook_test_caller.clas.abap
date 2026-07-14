CLASS zcl_webhook_test_caller DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

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
        iv_aufnr       TYPE string DEFAULT 'TEST0001'
        iv_werks       TYPE string DEFAULT '1000'
        io_out         TYPE REF TO if_oo_adt_classrun_out OPTIONAL.

ENDCLASS.


CLASS zcl_webhook_test_caller IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    run_test(
      iv_url = 'https://webhook.site/3225de9a-8ccf-4f29-9774-567b356fc37c'
      io_out = out ).
  ENDMETHOD.


  METHOD call_post.

    DATA: lo_destination TYPE REF TO if_http_destination,
          lo_http_client TYPE REF TO if_web_http_client,
          lo_request     TYPE REF TO if_web_http_request,
          lo_response    TYPE REF TO if_web_http_response,
          lv_scenario    TYPE c LENGTH 30.

    CLEAR: ev_status, ev_response, ev_message.

    TRY.
        IF iv_destination IS NOT INITIAL.
          lv_scenario = iv_destination.
          lo_destination = cl_http_destination_provider=>create_by_comm_arrangement(
                              comm_scenario = lv_scenario ).
        ELSEIF iv_url IS NOT INITIAL.
          lo_destination = cl_http_destination_provider=>create_by_url( iv_url ).
        ELSE.
          ev_message = 'Neither iv_destination nor iv_url supplied'.
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

    DATA: lv_payload  TYPE string,
          lv_status   TYPE i,
          lv_response TYPE string,
          lv_message  TYPE string.

    lv_payload = |\{ "orderNumber": "{ iv_aufnr }", "plant": "{ iv_werks }" \}|.

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
      io_out->write( |Status: { lv_status }| ).
      io_out->write( |Response: { lv_response }| ).
      io_out->write( |Message: { lv_message }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
