TYPES: BEGIN OF yy_alv_display,
         checkbox TYPE c LENGTH 1,
         status(12) TYPE c,
         remarks(100) TYPE c,
         lifnr LIKE bseg-lifnr,
         kunnr LIKE bseg-kunnr,
         belnr LIKE bseg-belnr,
         transaction_ref_no(15) TYPE c,
         rwbtr LIKE bseg-dmbtr,
         vend_name(140) TYPE c,
         vend_code like bseg-lifnr,
         line_color(4) TYPE c,
         pay_type(10) TYPE c,
         no_of_invoices TYPE i,
         pay_loc(35) TYPE c,
         print_loc(35) TYPE c,
         fis_yr LIKE bseg-gjahr,
         err_type TYPE i,
         chk_num TYPE payr-chect,
         debit_acc(30) TYPE c,
         val_date TYPE sy-datum,
         bene_add1(50) TYPE c,
         bene_add2(50) TYPE c,
         bene_acc(30) TYPE c,
         bene_ifsc(11) TYPE c,
         pin_code(10) TYPE c,
         handle TYPE i,
       END OF yy_alv_display.

TYPES: BEGIN OF ty_handle_map,
         vend_code TYPE lifnr,
         handle    TYPE i,
       END OF ty_handle_map.

TYPES: BEGIN OF ty_dropdown,
         vend_code TYPE lifnr,
         bene_acc  TYPE c LENGTH 40,
         bene_ifsc TYPE c LENGTH 40,
       END OF ty_dropdown.

DATA: go_container     TYPE REF TO cl_gui_custom_container,
      go_alv           TYPE REF TO cl_gui_alv_grid,
*      gt_alv_display   TYPE STANDARD TABLE OF yy_alv_display,
      gt_fcat          TYPE lvc_t_fcat,
      gs_fcat          TYPE lvc_s_fcat,
*      gs_layout        TYPE lvc_s_layo,
      gt_dropdown_vals TYPE lvc_t_drop,
      gs_dropdown_val  TYPE lvc_s_drop,
      gt_handle_map    TYPE STANDARD TABLE OF ty_handle_map,
      gs_handle_map    TYPE ty_handle_map,
      lt_dropdown      TYPE STANDARD TABLE OF ty_dropdown,
      ls_dropdown      TYPE ty_dropdown,
      lv_handle        TYPE i VALUE 1.

** Internal tables you already have
*DATA: it_bseg TYPE STANDARD TABLE OF bseg,
*      wa_bseg TYPE bseg,
*      it_lfbk TYPE STANDARD TABLE OF lfbk,
*      wa_lfbk TYPE lfbk.

START-OF-SELECTION.
   gt_alv_display[]  = it_alv_display[].
" Sample loop for collecting LFBK data
LOOP AT it_bseg INTO wa_bseg.

  SELECT lifnr, banks, bankl, bankn, bkref, bvtyp, koinh
    INTO TABLE @it_lfbk
    FROM lfbk
    WHERE lifnr = @wa_bseg-lifnr.

  LOOP AT it_lfbk INTO wa_lfbk.
    CLEAR ls_dropdown.
    ls_dropdown-vend_code = wa_lfbk-lifnr.
    ls_dropdown-bene_acc  = wa_lfbk-bankn.
    ls_dropdown-bene_ifsc = wa_lfbk-bankl.
    APPEND ls_dropdown TO lt_dropdown.
  ENDLOOP.

ENDLOOP.
*******************************************************
 DELETE ADJACENT DUPLICATES FROM lt_dropdown COMPARING vend_code bene_acc.


* Assign handle to each vendor in ALV display
LOOP AT gt_alv_display ASSIGNING FIELD-SYMBOL(<fs_row>).
  READ TABLE gt_handle_map WITH KEY vend_code = <fs_row>-vend_code INTO gs_handle_map.
  IF sy-subrc <> 0.
    gs_handle_map-vend_code = <fs_row>-vend_code.
    gs_handle_map-handle    = lv_handle.
    APPEND gs_handle_map TO gt_handle_map.
    lv_handle = lv_handle + 1.
  ENDIF.

  READ TABLE gt_handle_map WITH KEY vend_code = <fs_row>-vend_code INTO gs_handle_map.
  IF sy-subrc = 0.
    <fs_row>-handle = gs_handle_map-handle.
  ENDIF.
ENDLOOP.

* Build dropdown values
CLEAR gt_dropdown_vals.
LOOP AT lt_dropdown INTO ls_dropdown.
  READ TABLE gt_handle_map WITH KEY vend_code = ls_dropdown-vend_code INTO gs_handle_map.
  IF sy-subrc = 0.
    CLEAR gs_dropdown_val.
    gs_dropdown_val-handle = gs_handle_map-handle.
    gs_dropdown_val-value  = ls_dropdown-bene_acc.
    APPEND gs_dropdown_val TO gt_dropdown_vals.
  ENDIF.
ENDLOOP.

CALL SCREEN 100.

* ---------- Screen 100 PBO Module ----------
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.

  IF go_container IS INITIAL.

    CREATE OBJECT go_container
      EXPORTING container_name = 'CUST_CONT'.

    CREATE OBJECT go_alv
      EXPORTING i_parent = go_container.

    gr_alv_grid = go_alv.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'CHECKBOX'.
    gs_fcat-coltext   = 'Select'.
    gs_fcat-checkbox  = 'X'.
    gs_fcat-edit      = 'X'.
    gs_fcat-outputlen = 5.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'STATUS'.
    gs_fcat-coltext   = 'Status'.
    gs_fcat-outputlen = 16.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'REMARKS'.
    gs_fcat-coltext   = 'Remarks'.
    gs_fcat-outputlen = 20.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'BELNR'.
    gs_fcat-coltext   = 'Reference Number'.
    gs_fcat-outputlen = 16.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'DEBIT_ACC'.
    gs_fcat-coltext   = 'Debit Account'.
    gs_fcat-outputlen = 16.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'VEND_NAME'.
    gs_fcat-coltext   = 'Vendor Name'.
    gs_fcat-outputlen = 25.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'VEND_CODE'.
    gs_fcat-coltext   = 'Vendor Code'.
    gs_fcat-outputlen = 15.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'RWBTR'.
    gs_fcat-coltext   = 'Due Amount'.
    gs_fcat-outputlen = 18.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname  = 'BENE_ACC'.
    gs_fcat-coltext    = 'Beneficiary Account'.
    gs_fcat-outputlen  = 25.
    gs_fcat-edit       = 'X'.
    gs_fcat-drdn_field = 'HANDLE'.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'BENE_IFSC'.
    gs_fcat-coltext   = 'Beneficiary IFSC'.
    gs_fcat-outputlen = 16.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'BENE_ADD1'.
    gs_fcat-coltext   = 'Beneficiary Address'.
    gs_fcat-outputlen = 30.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'PIN_CODE'.
    gs_fcat-coltext   = 'Pin Code'.
    gs_fcat-outputlen = 10.
    APPEND gs_fcat TO gt_fcat.

    CLEAR gs_fcat.
    gs_fcat-fieldname = 'NO_OF_INVOICES'.
    gs_fcat-coltext   = 'No of Invoices'.
    gs_fcat-outputlen = 10.
    APPEND gs_fcat TO gt_fcat.

    gs_layout-edit = 'X'.  " Allow editing

    CALL METHOD go_alv->set_drop_down_table
      EXPORTING it_drop_down = gt_dropdown_vals.

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_alv_display
        it_fieldcatalog = gt_fcat.

  ENDIF.

ENDMODULE.




* === PAI ===
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    DATA: ls_row TYPE ty_alv_display.

    WHEN 'SAVE'.
          IF p_test IS  INITIAL.
            gv_x = 'X'.

            " Sync ALV changes to internal table
            IF go_alv IS BOUND.
              CALL METHOD go_alv->check_changed_data.
            ENDIF.

            " Delete unchecked rows from internal table
            DELETE gt_alv_display WHERE checkbox IS INITIAL.

            " Proceed only if there are checked rows
            IF gt_alv_display IS NOT INITIAL.

*               it_data = gt_alv_display .
*              PERFORM payment_details_construct.
              PERFORM payment_details_constructs.
              PERFORM extracted_alv_constructs.

            ELSE.
              MESSAGE 'Select the payments for approval' TYPE 'I'.
            ENDIF.

          ELSE.
            MESSAGE 'Remove Test Run' TYPE 'I'.
            endif.


      COMMIT WORK.

      MESSAGE 'Data saved successfully.' TYPE 'S'.


*       elseif WA_ALV_DISPLAY-STATUS = C_ERROR.
*
*  MESSAGE TEXT-073 TYPE 'E' DISPLAY LIKE 'I'.





    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.

