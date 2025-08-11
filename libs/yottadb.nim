
const
  YDB_DEL_TREE* = cuint(1)
const
  YDB_DEL_NODE* = cuint(2)
const
  YDB_SEVERITY_WARNING* = cuint(0)
const
  YDB_SEVERITY_SUCCESS* = cuint(1)
const
  YDB_SEVERITY_ERROR* = cuint(2)
const
  YDB_SEVERITY_INFORMATIONAL* = cuint(3)
const
  YDB_SEVERITY_FATAL* = cuint(4)
const
  YDB_DATA_UNDEF* = cuint(0)
const
  YDB_DATA_VALUE_NODESC* = cuint(1)
const
  YDB_DATA_NOVALUE_DESC* = cuint(10)
const
  YDB_DATA_VALUE_DESC* = cuint(11)
const
  YDB_DATA_ERROR* = cuint(2147483392)
const
  YDB_MAIN_LANG_C* = cuint(0)
const
  YDB_MAIN_LANG_GO* = cuint(1)
type
  struct_gparam_list_struct* {.pure, inheritable, bycopy.} = object
    n*: intptr_t             ## Generated based on /usr/local/lib/yottadb/r202/gparam_list.h:32:16
    arg*: array[36'i64, pointer]
  intptr_t* = clong          ## Generated based on /usr/include/stdint.h:76:19
  gparam_list* = struct_gparam_list_struct ## Generated based on /usr/local/lib/yottadb/r202/gparam_list.h:36:3
  ydb_status_t* = cint       ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:276:14
  ydb_int_t* = cint          ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:277:14
  ydb_uint_t* = cuint        ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:278:22
  ydb_long_t* = clong        ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:279:15
  ydb_ulong_t* = culong      ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:280:23
  ydb_int64_t* = int64       ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:281:18
  ydb_uint64_t* = uint64     ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:282:18
  ydb_float_t* = cfloat      ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:283:16
  ydb_double_t* = cdouble    ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:284:17
  ydb_char_t* = cschar       ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:285:15
  ydb_pointertofunc_t* = proc (): cint {.cdecl.} ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:286:16
  ydb_funcptr_retvoid_t* = proc (a0: intptr_t; a1: cuint; a2: cstring): void {.
      cdecl.}                ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:287:17
  struct_ydb_string_t* {.pure, inheritable, bycopy.} = object
    length*: culong          ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:293:9
    address*: cstring
  ydb_string_t* = struct_ydb_string_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:297:3
  struct_ydb_buffer_t* {.pure, inheritable, bycopy.} = object
    len_alloc*: cuint        ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:302:9
    len_used*: cuint
    buf_addr*: cstring
  ydb_buffer_t* = struct_ydb_buffer_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:307:3
  ydb_tid_t* = intptr_t      ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:309:18
  ydb_fileid_ptr_t* = pointer ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:310:16
  struct_ci_name_descriptor* {.pure, inheritable, bycopy.} = object
    rtn_name*: ydb_string_t  ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:316:9
    handle*: pointer
  ci_name_descriptor* = struct_ci_name_descriptor ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:320:3
  struct_ci_parm_type* {.pure, inheritable, bycopy.} = object
    input_mask*: cuint       ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:326:9
    output_mask*: cuint
  ci_parm_type* = struct_ci_parm_type ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:330:3
  ydb_jboolean_t* = ydb_int_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:333:19
  ydb_jint_t* = ydb_int_t    ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:334:19
  ydb_jlong_t* = ydb_long_t  ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:335:20
  ydb_jfloat_t* = ydb_float_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:336:21
  ydb_jdouble_t* = ydb_double_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:337:22
  ydb_jstring_t* = ydb_char_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:338:20
  ydb_jbyte_array_t* = ydb_char_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:339:20
  ydb_jbig_decimal_t* = ydb_char_t ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:340:20
  ydb_tpfnptr_t* = proc (a0: pointer): cint {.cdecl.} ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:343:16
  ydb_tp2fnptr_t* = proc (a0: uint64; a1: ptr ydb_buffer_t; a2: pointer): cint {.
      cdecl.}                ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:344:16
  ydb_vplist_func* = proc (): uintptr_t {.cdecl.} ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:345:21
  uintptr_t* = culong        ## Generated based on /usr/include/stdint.h:79:27
  GPCallback* = proc (a0: cint): void {.cdecl.} ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:346:17
when 4 is static:
  const
    PUSH_PARM_OVERHEAD* = 4  ## Generated based on /usr/local/lib/yottadb/r202/gparam_list.h:22:9
else:
  let PUSH_PARM_OVERHEAD* = 4 ## Generated based on /usr/local/lib/yottadb/r202/gparam_list.h:22:9
when 32 is static:
  const
    MAX_ACTUALS* = 32        ## Generated based on /usr/local/lib/yottadb/r202/gparam_list.h:27:9
else:
  let MAX_ACTUALS* = 32      ## Generated based on /usr/local/lib/yottadb/r202/gparam_list.h:27:9
when 202 is static:
  const
    YDB_RELEASE* = 202       ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:70:9
else:
  let YDB_RELEASE* = 202     ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:70:9
when 31 is static:
  const
    YDB_MAX_IDENT* = 31      ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:73:9
else:
  let YDB_MAX_IDENT* = 31    ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:73:9
when 35 is static:
  const
    YDB_MAX_NAMES* = 35      ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:74:9
else:
  let YDB_MAX_NAMES* = 35    ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:74:9
when 31 is static:
  const
    YDB_MAX_SUBS* = 31       ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:80:9
else:
  let YDB_MAX_SUBS* = 31     ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:80:9
when 32766 is static:
  const
    YDB_MAX_M_LINE_LEN* = 32766 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:86:9
else:
  let YDB_MAX_M_LINE_LEN* = 32766 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:86:9
when 32 is static:
  const
    YDB_MAX_PARMS* = 32      ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:88:9
else:
  let YDB_MAX_PARMS* = 32    ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:88:9
when 1024 is static:
  const
    YDB_MAX_ERRORMSG* = 1024 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:91:9
else:
  let YDB_MAX_ERRORMSG* = 1024 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:91:9
when 0 is static:
  const
    YDB_OK* = 0              ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:98:9
else:
  let YDB_OK* = 0            ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:98:9
when 32 is static:
  const
    DEFAULT_DATA_SIZE* = 32  ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:111:9
else:
  let DEFAULT_DATA_SIZE* = 32 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:111:9
when 2 is static:
  const
    DEFAULT_SUBSCR_CNT* = 2  ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:112:9
else:
  let DEFAULT_SUBSCR_CNT* = 2 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:112:9
when 16 is static:
  const
    DEFAULT_SUBSCR_SIZE* = 16 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:113:9
else:
  let DEFAULT_SUBSCR_SIZE* = 16 ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:113:9
when 1 is static:
  const
    TRUE* = 1                ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:117:10
else:
  let TRUE* = 1              ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:117:10
when 0 is static:
  const
    FALSE* = 0               ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:120:10
else:
  let FALSE* = 0             ## Generated based on /usr/local/lib/yottadb/r202/libyottadb.h:120:10
when -150372361 is static:
  const
    YDB_ERR_ACK* = -150372361 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:16:9
else:
  let YDB_ERR_ACK* = -150372361 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:16:9
when -150372371 is static:
  const
    YDB_ERR_BREAKZST* = -150372371 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:17:9
else:
  let YDB_ERR_BREAKZST* = -150372371 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:17:9
when -150372379 is static:
  const
    YDB_ERR_BADACCMTHD* = -150372379 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:18:9
else:
  let YDB_ERR_BADACCMTHD* = -150372379 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:18:9
when -150372386 is static:
  const
    YDB_ERR_BADJPIPARAM* = -150372386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:19:9
else:
  let YDB_ERR_BADJPIPARAM* = -150372386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:19:9
when -150372394 is static:
  const
    YDB_ERR_BADSYIPARAM* = -150372394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:20:9
else:
  let YDB_ERR_BADSYIPARAM* = -150372394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:20:9
when -150372402 is static:
  const
    YDB_ERR_BITMAPSBAD* = -150372402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:21:9
else:
  let YDB_ERR_BITMAPSBAD* = -150372402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:21:9
when -150372411 is static:
  const
    YDB_ERR_BREAK* = -150372411 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:22:9
else:
  let YDB_ERR_BREAK* = -150372411 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:22:9
when -150372419 is static:
  const
    YDB_ERR_BREAKDEA* = -150372419 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:23:9
else:
  let YDB_ERR_BREAKDEA* = -150372419 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:23:9
when -150372427 is static:
  const
    YDB_ERR_BREAKZBA* = -150372427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:24:9
else:
  let YDB_ERR_BREAKZBA* = -150372427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:24:9
when -150372435 is static:
  const
    YDB_ERR_STATCNT* = -150372435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:25:9
else:
  let YDB_ERR_STATCNT* = -150372435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:25:9
when -150372442 is static:
  const
    YDB_ERR_BTFAIL* = -150372442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:26:9
else:
  let YDB_ERR_BTFAIL* = -150372442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:26:9
when -150372450 is static:
  const
    YDB_ERR_MUPRECFLLCK* = -150372450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:27:9
else:
  let YDB_ERR_MUPRECFLLCK* = -150372450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:27:9
when -150372458 is static:
  const
    YDB_ERR_CMD* = -150372458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:28:9
else:
  let YDB_ERR_CMD* = -150372458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:28:9
when -150372466 is static:
  const
    YDB_ERR_COLON* = -150372466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:29:9
else:
  let YDB_ERR_COLON* = -150372466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:29:9
when -150372474 is static:
  const
    YDB_ERR_COMMA* = -150372474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:30:9
else:
  let YDB_ERR_COMMA* = -150372474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:30:9
when -150372482 is static:
  const
    YDB_ERR_COMMAORRPAREXP* = -150372482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:31:9
else:
  let YDB_ERR_COMMAORRPAREXP* = -150372482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:31:9
when -150372491 is static:
  const
    YDB_ERR_COMMENT* = -150372491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:32:9
else:
  let YDB_ERR_COMMENT* = -150372491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:32:9
when -150372498 is static:
  const
    YDB_ERR_CTRAP* = -150372498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:33:9
else:
  let YDB_ERR_CTRAP* = -150372498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:33:9
when -150372507 is static:
  const
    YDB_ERR_CTRLC* = -150372507 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:34:9
else:
  let YDB_ERR_CTRLC* = -150372507 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:34:9
when -150372515 is static:
  const
    YDB_ERR_CTRLY* = -150372515 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:35:9
else:
  let YDB_ERR_CTRLY* = -150372515 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:35:9
when -150372522 is static:
  const
    YDB_ERR_DBCCERR* = -150372522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:36:9
else:
  let YDB_ERR_DBCCERR* = -150372522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:36:9
when -150372530 is static:
  const
    YDB_ERR_DUPTOKEN* = -150372530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:37:9
else:
  let YDB_ERR_DUPTOKEN* = -150372530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:37:9
when -150372538 is static:
  const
    YDB_ERR_DBJNLNOTMATCH* = -150372538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:38:9
else:
  let YDB_ERR_DBJNLNOTMATCH* = -150372538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:38:9
when -150372546 is static:
  const
    YDB_ERR_DBFILERR* = -150372546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:39:9
else:
  let YDB_ERR_DBFILERR* = -150372546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:39:9
when -150372554 is static:
  const
    YDB_ERR_DBNOTGDS* = -150372554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:40:9
else:
  let YDB_ERR_DBNOTGDS* = -150372554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:40:9
when -418808018 is static:
  const
    YDB_ERR_DBOPNERR* = -418808018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:41:9
else:
  let YDB_ERR_DBOPNERR* = -418808018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:41:9
when -418808026 is static:
  const
    YDB_ERR_DBRDERR* = -418808026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:42:9
else:
  let YDB_ERR_DBRDERR* = -418808026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:42:9
when -150372580 is static:
  const
    YDB_ERR_UNUSEDMSG211* = -150372580 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:43:9
else:
  let YDB_ERR_UNUSEDMSG211* = -150372580 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:43:9
when -150372586 is static:
  const
    YDB_ERR_DEVPARINAP* = -150372586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:44:9
else:
  let YDB_ERR_DEVPARINAP* = -150372586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:44:9
when -150372595 is static:
  const
    YDB_ERR_RECORDSTAT* = -150372595 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:45:9
else:
  let YDB_ERR_RECORDSTAT* = -150372595 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:45:9
when -150372602 is static:
  const
    YDB_ERR_NOTGBL* = -150372602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:46:9
else:
  let YDB_ERR_NOTGBL* = -150372602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:46:9
when -150372610 is static:
  const
    YDB_ERR_DEVPARPROT* = -150372610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:47:9
else:
  let YDB_ERR_DEVPARPROT* = -150372610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:47:9
when -150372618 is static:
  const
    YDB_ERR_PREMATEOF* = -150372618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:48:9
else:
  let YDB_ERR_PREMATEOF* = -150372618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:48:9
when -150372626 is static:
  const
    YDB_ERR_GVINVALID* = -150372626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:49:9
else:
  let YDB_ERR_GVINVALID* = -150372626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:49:9
when -150372634 is static:
  const
    YDB_ERR_DEVPARTOOBIG* = -150372634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:50:9
else:
  let YDB_ERR_DEVPARTOOBIG* = -150372634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:50:9
when -150372642 is static:
  const
    YDB_ERR_DEVPARUNK* = -150372642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:51:9
else:
  let YDB_ERR_DEVPARUNK* = -150372642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:51:9
when -150372650 is static:
  const
    YDB_ERR_DEVPARVALREQ* = -150372650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:52:9
else:
  let YDB_ERR_DEVPARVALREQ* = -150372650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:52:9
when -150372658 is static:
  const
    YDB_ERR_DEVPARMNEG* = -150372658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:53:9
else:
  let YDB_ERR_DEVPARMNEG* = -150372658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:53:9
when -150372666 is static:
  const
    YDB_ERR_DSEBLKRDFAIL* = -150372666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:54:9
else:
  let YDB_ERR_DSEBLKRDFAIL* = -150372666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:54:9
when -150372674 is static:
  const
    YDB_ERR_DSEFAIL* = -150372674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:55:9
else:
  let YDB_ERR_DSEFAIL* = -150372674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:55:9
when -150372680 is static:
  const
    YDB_ERR_NOTALLREPLON* = -150372680 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:56:9
else:
  let YDB_ERR_NOTALLREPLON* = -150372680 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:56:9
when -150372690 is static:
  const
    YDB_ERR_BADLKIPARAM* = -150372690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:57:9
else:
  let YDB_ERR_BADLKIPARAM* = -150372690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:57:9
when -150372698 is static:
  const
    YDB_ERR_JNLREADBOF* = -150372698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:58:9
else:
  let YDB_ERR_JNLREADBOF* = -150372698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:58:9
when -150372706 is static:
  const
    YDB_ERR_DVIKEYBAD* = -150372706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:59:9
else:
  let YDB_ERR_DVIKEYBAD* = -150372706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:59:9
when -150372713 is static:
  const
    YDB_ERR_ENQ* = -150372713 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:60:9
else:
  let YDB_ERR_ENQ* = -150372713 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:60:9
when -150372722 is static:
  const
    YDB_ERR_EQUAL* = -150372722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:61:9
else:
  let YDB_ERR_EQUAL* = -150372722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:61:9
when -150372730 is static:
  const
    YDB_ERR_ERRORSUMMARY* = -150372730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:62:9
else:
  let YDB_ERR_ERRORSUMMARY* = -150372730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:62:9
when -150372738 is static:
  const
    YDB_ERR_ERRWEXC* = -150372738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:63:9
else:
  let YDB_ERR_ERRWEXC* = -150372738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:63:9
when -150372746 is static:
  const
    YDB_ERR_ERRWIOEXC* = -150372746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:64:9
else:
  let YDB_ERR_ERRWIOEXC* = -150372746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:64:9
when -150372754 is static:
  const
    YDB_ERR_ERRWZBRK* = -150372754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:65:9
else:
  let YDB_ERR_ERRWZBRK* = -150372754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:65:9
when -150372762 is static:
  const
    YDB_ERR_ERRWZTRAP* = -150372762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:66:9
else:
  let YDB_ERR_ERRWZTRAP* = -150372762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:66:9
when -150372770 is static:
  const
    YDB_ERR_NUMUNXEOR* = -150372770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:67:9
else:
  let YDB_ERR_NUMUNXEOR* = -150372770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:67:9
when -150372778 is static:
  const
    YDB_ERR_EXPR* = -150372778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:68:9
else:
  let YDB_ERR_EXPR* = -150372778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:68:9
when -150372786 is static:
  const
    YDB_ERR_STRUNXEOR* = -150372786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:69:9
else:
  let YDB_ERR_STRUNXEOR* = -150372786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:69:9
when -150372794 is static:
  const
    YDB_ERR_JNLEXTEND* = -150372794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:70:9
else:
  let YDB_ERR_JNLEXTEND* = -150372794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:70:9
when -150372802 is static:
  const
    YDB_ERR_FCHARMAXARGS* = -150372802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:71:9
else:
  let YDB_ERR_FCHARMAXARGS* = -150372802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:71:9
when -150372810 is static:
  const
    YDB_ERR_FCNSVNEXPECTED* = -150372810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:72:9
else:
  let YDB_ERR_FCNSVNEXPECTED* = -150372810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:72:9
when -150372818 is static:
  const
    YDB_ERR_FNARGINC* = -150372818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:73:9
else:
  let YDB_ERR_FNARGINC* = -150372818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:73:9
when -418808282 is static:
  const
    YDB_ERR_JNLACCESS* = -418808282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:74:9
else:
  let YDB_ERR_JNLACCESS* = -418808282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:74:9
when -150372834 is static:
  const
    YDB_ERR_TRANSNOSTART* = -150372834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:75:9
else:
  let YDB_ERR_TRANSNOSTART* = -150372834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:75:9
when -150372842 is static:
  const
    YDB_ERR_FNUMARG* = -150372842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:76:9
else:
  let YDB_ERR_FNUMARG* = -150372842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:76:9
when -150372850 is static:
  const
    YDB_ERR_FOROFLOW* = -150372850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:77:9
else:
  let YDB_ERR_FOROFLOW* = -150372850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:77:9
when -150372858 is static:
  const
    YDB_ERR_YDIRTSZ* = -150372858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:78:9
else:
  let YDB_ERR_YDIRTSZ* = -150372858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:78:9
when -150372865 is static:
  const
    YDB_ERR_JNLSUCCESS* = -150372865 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:79:9
else:
  let YDB_ERR_JNLSUCCESS* = -150372865 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:79:9
when -150372874 is static:
  const
    YDB_ERR_GBLNAME* = -150372874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:80:9
else:
  let YDB_ERR_GBLNAME* = -150372874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:80:9
when -150372882 is static:
  const
    YDB_ERR_GBLOFLOW* = -150372882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:81:9
else:
  let YDB_ERR_GBLOFLOW* = -150372882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:81:9
when -150372890 is static:
  const
    YDB_ERR_CORRUPT* = -150372890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:82:9
else:
  let YDB_ERR_CORRUPT* = -150372890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:82:9
when -150372900 is static:
  const
    YDB_ERR_GTMCHECK* = -150372900 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:83:9
else:
  let YDB_ERR_GTMCHECK* = -150372900 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:83:9
when -150372906 is static:
  const
    YDB_ERR_GVDATAFAIL* = -150372906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:84:9
else:
  let YDB_ERR_GVDATAFAIL* = -150372906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:84:9
when -150372914 is static:
  const
    YDB_ERR_EORNOTFND* = -150372914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:85:9
else:
  let YDB_ERR_EORNOTFND* = -150372914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:85:9
when -150372922 is static:
  const
    YDB_ERR_GVGETFAIL* = -150372922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:86:9
else:
  let YDB_ERR_GVGETFAIL* = -150372922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:86:9
when -150372931 is static:
  const
    YDB_ERR_GVIS* = -150372931 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:87:9
else:
  let YDB_ERR_GVIS* = -150372931 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:87:9
when -150372938 is static:
  const
    YDB_ERR_GVKILLFAIL* = -150372938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:88:9
else:
  let YDB_ERR_GVKILLFAIL* = -150372938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:88:9
when -150372946 is static:
  const
    YDB_ERR_GVNAKED* = -150372946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:89:9
else:
  let YDB_ERR_GVNAKED* = -150372946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:89:9
when -150372955 is static:
  const
    YDB_ERR_BACKUPDBFILE* = -150372955 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:90:9
else:
  let YDB_ERR_BACKUPDBFILE* = -150372955 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:90:9
when -150372962 is static:
  const
    YDB_ERR_GVORDERFAIL* = -150372962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:91:9
else:
  let YDB_ERR_GVORDERFAIL* = -150372962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:91:9
when -150372970 is static:
  const
    YDB_ERR_GVPUTFAIL* = -150372970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:92:9
else:
  let YDB_ERR_GVPUTFAIL* = -150372970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:92:9
when -150372978 is static:
  const
    YDB_ERR_PATTABSYNTAX* = -150372978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:93:9
else:
  let YDB_ERR_PATTABSYNTAX* = -150372978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:93:9
when -150372986 is static:
  const
    YDB_ERR_GVSUBOFLOW* = -150372986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:94:9
else:
  let YDB_ERR_GVSUBOFLOW* = -150372986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:94:9
when -150372994 is static:
  const
    YDB_ERR_GVUNDEF* = -150372994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:95:9
else:
  let YDB_ERR_GVUNDEF* = -150372994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:95:9
when -150373002 is static:
  const
    YDB_ERR_TRANSNEST* = -150373002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:96:9
else:
  let YDB_ERR_TRANSNEST* = -150373002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:96:9
when -150373010 is static:
  const
    YDB_ERR_INDEXTRACHARS* = -150373010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:97:9
else:
  let YDB_ERR_INDEXTRACHARS* = -150373010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:97:9
when -150373018 is static:
  const
    YDB_ERR_CORRUPTNODE* = -150373018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:98:9
else:
  let YDB_ERR_CORRUPTNODE* = -150373018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:98:9
when -150373026 is static:
  const
    YDB_ERR_INDRMAXLEN* = -150373026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:99:9
else:
  let YDB_ERR_INDRMAXLEN* = -150373026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:99:9
when -150373034 is static:
  const
    YDB_ERR_UNUSEDMSG268* = -150373034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:100:9
else:
  let YDB_ERR_UNUSEDMSG268* = -150373034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:100:9
when -150373042 is static:
  const
    YDB_ERR_INTEGERRS* = -150373042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:101:9
else:
  let YDB_ERR_INTEGERRS* = -150373042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:101:9
when -150373048 is static:
  const
    YDB_ERR_INVCMD* = -150373048 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:102:9
else:
  let YDB_ERR_INVCMD* = -150373048 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:102:9
when -150373058 is static:
  const
    YDB_ERR_INVFCN* = -150373058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:103:9
else:
  let YDB_ERR_INVFCN* = -150373058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:103:9
when -150373066 is static:
  const
    YDB_ERR_INVOBJ* = -150373066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:104:9
else:
  let YDB_ERR_INVOBJ* = -150373066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:104:9
when -150373074 is static:
  const
    YDB_ERR_INVSVN* = -150373074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:105:9
else:
  let YDB_ERR_INVSVN* = -150373074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:105:9
when -150373082 is static:
  const
    YDB_ERR_IOEOF* = -150373082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:106:9
else:
  let YDB_ERR_IOEOF* = -150373082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:106:9
when -150373090 is static:
  const
    YDB_ERR_IONOTOPEN* = -150373090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:107:9
else:
  let YDB_ERR_IONOTOPEN* = -150373090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:107:9
when -150373099 is static:
  const
    YDB_ERR_MUPIPINFO* = -150373099 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:108:9
else:
  let YDB_ERR_MUPIPINFO* = -150373099 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:108:9
when -150373106 is static:
  const
    YDB_ERR_UNUSEDMSG277* = -150373106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:109:9
else:
  let YDB_ERR_UNUSEDMSG277* = -150373106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:109:9
when -150373114 is static:
  const
    YDB_ERR_JOBFAIL* = -150373114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:110:9
else:
  let YDB_ERR_JOBFAIL* = -150373114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:110:9
when -150373122 is static:
  const
    YDB_ERR_JOBLABOFF* = -150373122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:111:9
else:
  let YDB_ERR_JOBLABOFF* = -150373122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:111:9
when -150373130 is static:
  const
    YDB_ERR_JOBPARNOVAL* = -150373130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:112:9
else:
  let YDB_ERR_JOBPARNOVAL* = -150373130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:112:9
when -150373138 is static:
  const
    YDB_ERR_JOBPARNUM* = -150373138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:113:9
else:
  let YDB_ERR_JOBPARNUM* = -150373138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:113:9
when -150373146 is static:
  const
    YDB_ERR_JOBPARSTR* = -150373146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:114:9
else:
  let YDB_ERR_JOBPARSTR* = -150373146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:114:9
when -150373154 is static:
  const
    YDB_ERR_JOBPARUNK* = -150373154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:115:9
else:
  let YDB_ERR_JOBPARUNK* = -150373154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:115:9
when -150373162 is static:
  const
    YDB_ERR_JOBPARVALREQ* = -150373162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:116:9
else:
  let YDB_ERR_JOBPARVALREQ* = -150373162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:116:9
when -150373170 is static:
  const
    YDB_ERR_JUSTFRACT* = -150373170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:117:9
else:
  let YDB_ERR_JUSTFRACT* = -150373170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:117:9
when -150373178 is static:
  const
    YDB_ERR_KEY2BIG* = -150373178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:118:9
else:
  let YDB_ERR_KEY2BIG* = -150373178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:118:9
when -150373186 is static:
  const
    YDB_ERR_LABELEXPECTED* = -150373186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:119:9
else:
  let YDB_ERR_LABELEXPECTED* = -150373186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:119:9
when -150373194 is static:
  const
    YDB_ERR_LABELMISSING* = -150373194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:120:9
else:
  let YDB_ERR_LABELMISSING* = -150373194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:120:9
when -150373202 is static:
  const
    YDB_ERR_LABELUNKNOWN* = -150373202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:121:9
else:
  let YDB_ERR_LABELUNKNOWN* = -150373202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:121:9
when -150373210 is static:
  const
    YDB_ERR_DIVZERO* = -150373210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:122:9
else:
  let YDB_ERR_DIVZERO* = -150373210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:122:9
when -150373218 is static:
  const
    YDB_ERR_LKNAMEXPECTED* = -150373218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:123:9
else:
  let YDB_ERR_LKNAMEXPECTED* = -150373218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:123:9
when -418808682 is static:
  const
    YDB_ERR_JNLRDERR* = -418808682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:124:9
else:
  let YDB_ERR_JNLRDERR* = -418808682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:124:9
when -150373234 is static:
  const
    YDB_ERR_LOADRUNNING* = -150373234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:125:9
else:
  let YDB_ERR_LOADRUNNING* = -150373234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:125:9
when -150373242 is static:
  const
    YDB_ERR_LPARENMISSING* = -150373242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:126:9
else:
  let YDB_ERR_LPARENMISSING* = -150373242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:126:9
when -150373250 is static:
  const
    YDB_ERR_LSEXPECTED* = -150373250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:127:9
else:
  let YDB_ERR_LSEXPECTED* = -150373250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:127:9
when -150373258 is static:
  const
    YDB_ERR_LVORDERARG* = -150373258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:128:9
else:
  let YDB_ERR_LVORDERARG* = -150373258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:128:9
when -150373266 is static:
  const
    YDB_ERR_MAXFORARGS* = -150373266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:129:9
else:
  let YDB_ERR_MAXFORARGS* = -150373266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:129:9
when -150373274 is static:
  const
    YDB_ERR_TRANSMINUS* = -150373274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:130:9
else:
  let YDB_ERR_TRANSMINUS* = -150373274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:130:9
when -150373282 is static:
  const
    YDB_ERR_MAXNRSUBSCRIPTS* = -150373282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:131:9
else:
  let YDB_ERR_MAXNRSUBSCRIPTS* = -150373282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:131:9
when -150373290 is static:
  const
    YDB_ERR_MAXSTRLEN* = -150373290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:132:9
else:
  let YDB_ERR_MAXSTRLEN* = -150373290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:132:9
when -150373296 is static:
  const
    YDB_ERR_ENCRYPTCONFLT2* = -150373296 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:133:9
else:
  let YDB_ERR_ENCRYPTCONFLT2* = -150373296 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:133:9
when -150373306 is static:
  const
    YDB_ERR_JNLFILOPN* = -150373306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:134:9
else:
  let YDB_ERR_JNLFILOPN* = -150373306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:134:9
when -418808770 is static:
  const
    YDB_ERR_MBXRDONLY* = -418808770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:135:9
else:
  let YDB_ERR_MBXRDONLY* = -418808770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:135:9
when -150373322 is static:
  const
    YDB_ERR_JNLINVALID* = -150373322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:136:9
else:
  let YDB_ERR_JNLINVALID* = -150373322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:136:9
when -418808786 is static:
  const
    YDB_ERR_MBXWRTONLY* = -418808786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:137:9
else:
  let YDB_ERR_MBXWRTONLY* = -418808786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:137:9
when -150373340 is static:
  const
    YDB_ERR_MEMORY* = -150373340 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:138:9
else:
  let YDB_ERR_MEMORY* = -150373340 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:138:9
when -150373344 is static:
  const
    YDB_ERR_DONOBLOCK* = -150373344 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:139:9
else:
  let YDB_ERR_DONOBLOCK* = -150373344 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:139:9
when -150373354 is static:
  const
    YDB_ERR_ZATRANSCOL* = -150373354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:140:9
else:
  let YDB_ERR_ZATRANSCOL* = -150373354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:140:9
when -150373360 is static:
  const
    YDB_ERR_VIEWREGLIST* = -150373360 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:141:9
else:
  let YDB_ERR_VIEWREGLIST* = -150373360 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:141:9
when -150373370 is static:
  const
    YDB_ERR_NUMERR* = -150373370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:142:9
else:
  let YDB_ERR_NUMERR* = -150373370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:142:9
when -150373378 is static:
  const
    YDB_ERR_NUM64ERR* = -150373378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:143:9
else:
  let YDB_ERR_NUM64ERR* = -150373378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:143:9
when -150373386 is static:
  const
    YDB_ERR_UNUM64ERR* = -150373386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:144:9
else:
  let YDB_ERR_UNUM64ERR* = -150373386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:144:9
when -150373394 is static:
  const
    YDB_ERR_HEXERR* = -150373394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:145:9
else:
  let YDB_ERR_HEXERR* = -150373394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:145:9
when -150373402 is static:
  const
    YDB_ERR_HEX64ERR* = -150373402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:146:9
else:
  let YDB_ERR_HEX64ERR* = -150373402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:146:9
when -150373410 is static:
  const
    YDB_ERR_CMDERR* = -150373410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:147:9
else:
  let YDB_ERR_CMDERR* = -150373410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:147:9
when -150373419 is static:
  const
    YDB_ERR_BACKUPSUCCESS* = -150373419 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:148:9
else:
  let YDB_ERR_BACKUPSUCCESS* = -150373419 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:148:9
when -150373426 is static:
  const
    YDB_ERR_JNLTMQUAL3* = -150373426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:149:9
else:
  let YDB_ERR_JNLTMQUAL3* = -150373426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:149:9
when -150373434 is static:
  const
    YDB_ERR_MULTLAB* = -150373434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:150:9
else:
  let YDB_ERR_MULTLAB* = -150373434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:150:9
when -150373442 is static:
  const
    YDB_ERR_GTMCURUNSUPP* = -150373442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:151:9
else:
  let YDB_ERR_GTMCURUNSUPP* = -150373442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:151:9
when -150373452 is static:
  const
    YDB_ERR_UNUSEDMSG320* = -150373452 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:152:9
else:
  let YDB_ERR_UNUSEDMSG320* = -150373452 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:152:9
when -150373458 is static:
  const
    YDB_ERR_NOPLACE* = -150373458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:153:9
else:
  let YDB_ERR_NOPLACE* = -150373458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:153:9
when -150373466 is static:
  const
    YDB_ERR_JNLCLOSE* = -150373466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:154:9
else:
  let YDB_ERR_JNLCLOSE* = -150373466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:154:9
when -150373472 is static:
  const
    YDB_ERR_NOTPRINCIO* = -150373472 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:155:9
else:
  let YDB_ERR_NOTPRINCIO* = -150373472 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:155:9
when -150373482 is static:
  const
    YDB_ERR_NOTTOEOFONPUT* = -150373482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:156:9
else:
  let YDB_ERR_NOTTOEOFONPUT* = -150373482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:156:9
when -150373491 is static:
  const
    YDB_ERR_NOZBRK* = -150373491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:157:9
else:
  let YDB_ERR_NOZBRK* = -150373491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:157:9
when -150373498 is static:
  const
    YDB_ERR_NULSUBSC* = -150373498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:158:9
else:
  let YDB_ERR_NULSUBSC* = -150373498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:158:9
when -150373506 is static:
  const
    YDB_ERR_NUMOFLOW* = -150373506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:159:9
else:
  let YDB_ERR_NUMOFLOW* = -150373506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:159:9
when -150373514 is static:
  const
    YDB_ERR_PARFILSPC* = -150373514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:160:9
else:
  let YDB_ERR_PARFILSPC* = -150373514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:160:9
when -150373522 is static:
  const
    YDB_ERR_PATCLASS* = -150373522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:161:9
else:
  let YDB_ERR_PATCLASS* = -150373522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:161:9
when -150373530 is static:
  const
    YDB_ERR_PATCODE* = -150373530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:162:9
else:
  let YDB_ERR_PATCODE* = -150373530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:162:9
when -150373538 is static:
  const
    YDB_ERR_PATLIT* = -150373538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:163:9
else:
  let YDB_ERR_PATLIT* = -150373538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:163:9
when -150373546 is static:
  const
    YDB_ERR_PATMAXLEN* = -150373546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:164:9
else:
  let YDB_ERR_PATMAXLEN* = -150373546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:164:9
when -150373554 is static:
  const
    YDB_ERR_LPARENREQD* = -150373554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:165:9
else:
  let YDB_ERR_LPARENREQD* = -150373554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:165:9
when -150373562 is static:
  const
    YDB_ERR_PATUPPERLIM* = -150373562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:166:9
else:
  let YDB_ERR_PATUPPERLIM* = -150373562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:166:9
when -150373570 is static:
  const
    YDB_ERR_PCONDEXPECTED* = -150373570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:167:9
else:
  let YDB_ERR_PCONDEXPECTED* = -150373570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:167:9
when -150373578 is static:
  const
    YDB_ERR_PRCNAMLEN* = -150373578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:168:9
else:
  let YDB_ERR_PRCNAMLEN* = -150373578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:168:9
when -150373586 is static:
  const
    YDB_ERR_RANDARGNEG* = -150373586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:169:9
else:
  let YDB_ERR_RANDARGNEG* = -150373586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:169:9
when -418809050 is static:
  const
    YDB_ERR_DBPRIVERR* = -418809050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:170:9
else:
  let YDB_ERR_DBPRIVERR* = -418809050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:170:9
when -150373602 is static:
  const
    YDB_ERR_REC2BIG* = -150373602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:171:9
else:
  let YDB_ERR_REC2BIG* = -150373602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:171:9
when -150373610 is static:
  const
    YDB_ERR_RHMISSING* = -150373610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:172:9
else:
  let YDB_ERR_RHMISSING* = -150373610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:172:9
when -150373618 is static:
  const
    YDB_ERR_DEVICEREADONLY* = -150373618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:173:9
else:
  let YDB_ERR_DEVICEREADONLY* = -150373618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:173:9
when -150373626 is static:
  const
    YDB_ERR_COLLDATAEXISTS* = -150373626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:174:9
else:
  let YDB_ERR_COLLDATAEXISTS* = -150373626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:174:9
when -150373634 is static:
  const
    YDB_ERR_ROUTINEUNKNOWN* = -150373634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:175:9
else:
  let YDB_ERR_ROUTINEUNKNOWN* = -150373634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:175:9
when -150373642 is static:
  const
    YDB_ERR_RPARENMISSING* = -150373642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:176:9
else:
  let YDB_ERR_RPARENMISSING* = -150373642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:176:9
when -150373650 is static:
  const
    YDB_ERR_RTNNAME* = -150373650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:177:9
else:
  let YDB_ERR_RTNNAME* = -150373650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:177:9
when -150373658 is static:
  const
    YDB_ERR_VIEWGVN* = -150373658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:178:9
else:
  let YDB_ERR_VIEWGVN* = -150373658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:178:9
when -150373667 is static:
  const
    YDB_ERR_RTSLOC* = -150373667 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:179:9
else:
  let YDB_ERR_RTSLOC* = -150373667 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:179:9
when -150373674 is static:
  const
    YDB_ERR_RWARG* = -150373674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:180:9
else:
  let YDB_ERR_RWARG* = -150373674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:180:9
when -150373682 is static:
  const
    YDB_ERR_RWFORMAT* = -150373682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:181:9
else:
  let YDB_ERR_RWFORMAT* = -150373682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:181:9
when -150373691 is static:
  const
    YDB_ERR_JNLWRTDEFER* = -150373691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:182:9
else:
  let YDB_ERR_JNLWRTDEFER* = -150373691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:182:9
when -150373698 is static:
  const
    YDB_ERR_SELECTFALSE* = -150373698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:183:9
else:
  let YDB_ERR_SELECTFALSE* = -150373698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:183:9
when -150373706 is static:
  const
    YDB_ERR_SPOREOL* = -150373706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:184:9
else:
  let YDB_ERR_SPOREOL* = -150373706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:184:9
when -150373715 is static:
  const
    YDB_ERR_SRCLIN* = -150373715 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:185:9
else:
  let YDB_ERR_SRCLIN* = -150373715 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:185:9
when -150373723 is static:
  const
    YDB_ERR_SRCLOC* = -150373723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:186:9
else:
  let YDB_ERR_SRCLOC* = -150373723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:186:9
when -150373728 is static:
  const
    YDB_ERR_RLNKRECNFL* = -150373728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:187:9
else:
  let YDB_ERR_RLNKRECNFL* = -150373728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:187:9
when -150373738 is static:
  const
    YDB_ERR_STACKCRIT* = -150373738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:188:9
else:
  let YDB_ERR_STACKCRIT* = -150373738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:188:9
when -150373748 is static:
  const
    YDB_ERR_STACKOFLOW* = -150373748 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:189:9
else:
  let YDB_ERR_STACKOFLOW* = -150373748 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:189:9
when -150373754 is static:
  const
    YDB_ERR_STACKUNDERFLO* = -150373754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:190:9
else:
  let YDB_ERR_STACKUNDERFLO* = -150373754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:190:9
when -150373762 is static:
  const
    YDB_ERR_STRINGOFLOW* = -150373762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:191:9
else:
  let YDB_ERR_STRINGOFLOW* = -150373762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:191:9
when -150373770 is static:
  const
    YDB_ERR_SVNOSET* = -150373770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:192:9
else:
  let YDB_ERR_SVNOSET* = -150373770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:192:9
when -150373778 is static:
  const
    YDB_ERR_VIEWFN* = -150373778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:193:9
else:
  let YDB_ERR_VIEWFN* = -150373778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:193:9
when -150373786 is static:
  const
    YDB_ERR_TERMASTQUOTA* = -150373786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:194:9
else:
  let YDB_ERR_TERMASTQUOTA* = -150373786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:194:9
when -150373794 is static:
  const
    YDB_ERR_TEXTARG* = -150373794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:195:9
else:
  let YDB_ERR_TEXTARG* = -150373794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:195:9
when -150373802 is static:
  const
    YDB_ERR_TMPSTOREMAX* = -150373802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:196:9
else:
  let YDB_ERR_TMPSTOREMAX* = -150373802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:196:9
when -150373810 is static:
  const
    YDB_ERR_VIEWCMD* = -150373810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:197:9
else:
  let YDB_ERR_VIEWCMD* = -150373810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:197:9
when -150373818 is static:
  const
    YDB_ERR_JNI* = -150373818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:198:9
else:
  let YDB_ERR_JNI* = -150373818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:198:9
when -150373826 is static:
  const
    YDB_ERR_TXTSRCFMT* = -150373826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:199:9
else:
  let YDB_ERR_TXTSRCFMT* = -150373826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:199:9
when -150373834 is static:
  const
    YDB_ERR_UIDMSG* = -150373834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:200:9
else:
  let YDB_ERR_UIDMSG* = -150373834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:200:9
when -150373842 is static:
  const
    YDB_ERR_UIDSND* = -150373842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:201:9
else:
  let YDB_ERR_UIDSND* = -150373842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:201:9
when -150373850 is static:
  const
    YDB_ERR_LVUNDEF* = -150373850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:202:9
else:
  let YDB_ERR_LVUNDEF* = -150373850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:202:9
when -150373858 is static:
  const
    YDB_ERR_UNIMPLOP* = -150373858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:203:9
else:
  let YDB_ERR_UNIMPLOP* = -150373858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:203:9
when -150373866 is static:
  const
    YDB_ERR_VAREXPECTED* = -150373866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:204:9
else:
  let YDB_ERR_VAREXPECTED* = -150373866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:204:9
when -150373874 is static:
  const
    YDB_ERR_BACKUPFAIL* = -150373874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:205:9
else:
  let YDB_ERR_BACKUPFAIL* = -150373874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:205:9
when -150373882 is static:
  const
    YDB_ERR_MAXARGCNT* = -150373882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:206:9
else:
  let YDB_ERR_MAXARGCNT* = -150373882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:206:9
when -150373892 is static:
  const
    YDB_ERR_GTMSECSHRSEMGET* = -150373892 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:207:9
else:
  let YDB_ERR_GTMSECSHRSEMGET* = -150373892 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:207:9
when -150373898 is static:
  const
    YDB_ERR_VIEWARGCNT* = -150373898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:208:9
else:
  let YDB_ERR_VIEWARGCNT* = -150373898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:208:9
when -150373907 is static:
  const
    YDB_ERR_GTMSECSHRDMNSTARTED* = -150373907 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:209:9
else:
  let YDB_ERR_GTMSECSHRDMNSTARTED* = -150373907 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:209:9
when -150373914 is static:
  const
    YDB_ERR_ZATTACHERR* = -150373914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:210:9
else:
  let YDB_ERR_ZATTACHERR* = -150373914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:210:9
when -150373922 is static:
  const
    YDB_ERR_ZDATEFMT* = -150373922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:211:9
else:
  let YDB_ERR_ZDATEFMT* = -150373922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:211:9
when -150373930 is static:
  const
    YDB_ERR_ZEDFILSPEC* = -150373930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:212:9
else:
  let YDB_ERR_ZEDFILSPEC* = -150373930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:212:9
when -150373938 is static:
  const
    YDB_ERR_ZFILENMTOOLONG* = -150373938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:213:9
else:
  let YDB_ERR_ZFILENMTOOLONG* = -150373938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:213:9
when -150373946 is static:
  const
    YDB_ERR_ZFILKEYBAD* = -150373946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:214:9
else:
  let YDB_ERR_ZFILKEYBAD* = -150373946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:214:9
when -150373954 is static:
  const
    YDB_ERR_ZFILNMBAD* = -150373954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:215:9
else:
  let YDB_ERR_ZFILNMBAD* = -150373954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:215:9
when -150373962 is static:
  const
    YDB_ERR_ZGOTOLTZERO* = -150373962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:216:9
else:
  let YDB_ERR_ZGOTOLTZERO* = -150373962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:216:9
when -150373970 is static:
  const
    YDB_ERR_ZGOTOTOOBIG* = -150373970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:217:9
else:
  let YDB_ERR_ZGOTOTOOBIG* = -150373970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:217:9
when -150373978 is static:
  const
    YDB_ERR_ZLINKFILE* = -150373978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:218:9
else:
  let YDB_ERR_ZLINKFILE* = -150373978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:218:9
when -150373986 is static:
  const
    YDB_ERR_ZPARSETYPE* = -150373986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:219:9
else:
  let YDB_ERR_ZPARSETYPE* = -150373986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:219:9
when -150373994 is static:
  const
    YDB_ERR_ZPARSFLDBAD* = -150373994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:220:9
else:
  let YDB_ERR_ZPARSFLDBAD* = -150373994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:220:9
when -150374002 is static:
  const
    YDB_ERR_ZPIDBADARG* = -150374002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:221:9
else:
  let YDB_ERR_ZPIDBADARG* = -150374002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:221:9
when -150374010 is static:
  const
    YDB_ERR_UNUSEDMSG390* = -150374010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:222:9
else:
  let YDB_ERR_UNUSEDMSG390* = -150374010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:222:9
when -150374018 is static:
  const
    YDB_ERR_UNUSEDMSG391* = -150374018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:223:9
else:
  let YDB_ERR_UNUSEDMSG391* = -150374018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:223:9
when -150374026 is static:
  const
    YDB_ERR_ZPRTLABNOTFND* = -150374026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:224:9
else:
  let YDB_ERR_ZPRTLABNOTFND* = -150374026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:224:9
when -150374034 is static:
  const
    YDB_ERR_VIEWAMBIG* = -150374034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:225:9
else:
  let YDB_ERR_VIEWAMBIG* = -150374034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:225:9
when -150374042 is static:
  const
    YDB_ERR_VIEWNOTFOUND* = -150374042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:226:9
else:
  let YDB_ERR_VIEWNOTFOUND* = -150374042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:226:9
when -150374050 is static:
  const
    YDB_ERR_UNUSEDMSG395* = -150374050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:227:9
else:
  let YDB_ERR_UNUSEDMSG395* = -150374050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:227:9
when -150374058 is static:
  const
    YDB_ERR_INVSPECREC* = -150374058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:228:9
else:
  let YDB_ERR_INVSPECREC* = -150374058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:228:9
when -150374066 is static:
  const
    YDB_ERR_UNUSEDMSG397* = -150374066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:229:9
else:
  let YDB_ERR_UNUSEDMSG397* = -150374066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:229:9
when -150374074 is static:
  const
    YDB_ERR_ZSRCHSTRMCT* = -150374074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:230:9
else:
  let YDB_ERR_ZSRCHSTRMCT* = -150374074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:230:9
when -150374082 is static:
  const
    YDB_ERR_VERSION* = -150374082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:231:9
else:
  let YDB_ERR_VERSION* = -150374082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:231:9
when -150374088 is static:
  const
    YDB_ERR_MUNOTALLSEC* = -150374088 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:232:9
else:
  let YDB_ERR_MUNOTALLSEC* = -150374088 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:232:9
when -150374099 is static:
  const
    YDB_ERR_MUSECDEL* = -150374099 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:233:9
else:
  let YDB_ERR_MUSECDEL* = -150374099 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:233:9
when -150374107 is static:
  const
    YDB_ERR_MUSECNOTDEL* = -150374107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:234:9
else:
  let YDB_ERR_MUSECNOTDEL* = -150374107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:234:9
when -150374114 is static:
  const
    YDB_ERR_RPARENREQD* = -150374114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:235:9
else:
  let YDB_ERR_RPARENREQD* = -150374114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:235:9
when -418809578 is static:
  const
    YDB_ERR_ZGBLDIRACC* = -418809578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:236:9
else:
  let YDB_ERR_ZGBLDIRACC* = -418809578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:236:9
when -150374130 is static:
  const
    YDB_ERR_GVNAKEDEXTNM* = -150374130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:237:9
else:
  let YDB_ERR_GVNAKEDEXTNM* = -150374130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:237:9
when -150374138 is static:
  const
    YDB_ERR_EXTGBLDEL* = -150374138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:238:9
else:
  let YDB_ERR_EXTGBLDEL* = -150374138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:238:9
when -150374147 is static:
  const
    YDB_ERR_DSEWCINITCON* = -150374147 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:239:9
else:
  let YDB_ERR_DSEWCINITCON* = -150374147 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:239:9
when -150374155 is static:
  const
    YDB_ERR_LASTFILCMPLD* = -150374155 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:240:9
else:
  let YDB_ERR_LASTFILCMPLD* = -150374155 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:240:9
when -150374163 is static:
  const
    YDB_ERR_NOEXCNOZTRAP* = -150374163 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:241:9
else:
  let YDB_ERR_NOEXCNOZTRAP* = -150374163 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:241:9
when -150374170 is static:
  const
    YDB_ERR_UNSDCLASS* = -150374170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:242:9
else:
  let YDB_ERR_UNSDCLASS* = -150374170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:242:9
when -150374178 is static:
  const
    YDB_ERR_UNSDDTYPE* = -150374178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:243:9
else:
  let YDB_ERR_UNSDDTYPE* = -150374178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:243:9
when -150374186 is static:
  const
    YDB_ERR_ZCUNKTYPE* = -150374186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:244:9
else:
  let YDB_ERR_ZCUNKTYPE* = -150374186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:244:9
when -150374194 is static:
  const
    YDB_ERR_ZCUNKMECH* = -150374194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:245:9
else:
  let YDB_ERR_ZCUNKMECH* = -150374194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:245:9
when -150374202 is static:
  const
    YDB_ERR_ZCUNKQUAL* = -150374202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:246:9
else:
  let YDB_ERR_ZCUNKQUAL* = -150374202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:246:9
when -150374210 is static:
  const
    YDB_ERR_JNLDBTNNOMATCH* = -150374210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:247:9
else:
  let YDB_ERR_JNLDBTNNOMATCH* = -150374210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:247:9
when -150374218 is static:
  const
    YDB_ERR_ZCALLTABLE* = -150374218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:248:9
else:
  let YDB_ERR_ZCALLTABLE* = -150374218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:248:9
when -150374226 is static:
  const
    YDB_ERR_ZCARGMSMTCH* = -150374226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:249:9
else:
  let YDB_ERR_ZCARGMSMTCH* = -150374226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:249:9
when -150374234 is static:
  const
    YDB_ERR_ZCCONMSMTCH* = -150374234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:250:9
else:
  let YDB_ERR_ZCCONMSMTCH* = -150374234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:250:9
when -150374242 is static:
  const
    YDB_ERR_ZCOPT0* = -150374242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:251:9
else:
  let YDB_ERR_ZCOPT0* = -150374242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:251:9
when -150374250 is static:
  const
    YDB_ERR_UNUSEDMSG420* = -150374250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:252:9
else:
  let YDB_ERR_UNUSEDMSG420* = -150374250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:252:9
when -150374258 is static:
  const
    YDB_ERR_UNUSEDMSG421* = -150374258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:253:9
else:
  let YDB_ERR_UNUSEDMSG421* = -150374258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:253:9
when -150374266 is static:
  const
    YDB_ERR_ZCPOSOVR* = -150374266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:254:9
else:
  let YDB_ERR_ZCPOSOVR* = -150374266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:254:9
when -150374274 is static:
  const
    YDB_ERR_ZCINPUTREQ* = -150374274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:255:9
else:
  let YDB_ERR_ZCINPUTREQ* = -150374274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:255:9
when -150374282 is static:
  const
    YDB_ERR_JNLTNOUTOFSEQ* = -150374282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:256:9
else:
  let YDB_ERR_JNLTNOUTOFSEQ* = -150374282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:256:9
when -150374290 is static:
  const
    YDB_ERR_ACTRANGE* = -150374290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:257:9
else:
  let YDB_ERR_ACTRANGE* = -150374290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:257:9
when -150374298 is static:
  const
    YDB_ERR_ZCCONVERT* = -150374298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:258:9
else:
  let YDB_ERR_ZCCONVERT* = -150374298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:258:9
when -150374306 is static:
  const
    YDB_ERR_ZCRTENOTF* = -150374306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:259:9
else:
  let YDB_ERR_ZCRTENOTF* = -150374306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:259:9
when -150374314 is static:
  const
    YDB_ERR_GVRUNDOWN* = -150374314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:260:9
else:
  let YDB_ERR_GVRUNDOWN* = -150374314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:260:9
when -150374322 is static:
  const
    YDB_ERR_LKRUNDOWN* = -150374322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:261:9
else:
  let YDB_ERR_LKRUNDOWN* = -150374322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:261:9
when -150374330 is static:
  const
    YDB_ERR_IORUNDOWN* = -150374330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:262:9
else:
  let YDB_ERR_IORUNDOWN* = -150374330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:262:9
when -150374338 is static:
  const
    YDB_ERR_FILENOTFND* = -150374338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:263:9
else:
  let YDB_ERR_FILENOTFND* = -150374338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:263:9
when -150374346 is static:
  const
    YDB_ERR_MUFILRNDWNFL* = -150374346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:264:9
else:
  let YDB_ERR_MUFILRNDWNFL* = -150374346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:264:9
when -150374354 is static:
  const
    YDB_ERR_JNLTMQUAL1* = -150374354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:265:9
else:
  let YDB_ERR_JNLTMQUAL1* = -150374354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:265:9
when -150374364 is static:
  const
    YDB_ERR_FORCEDHALT* = -150374364 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:266:9
else:
  let YDB_ERR_FORCEDHALT* = -150374364 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:266:9
when -150374370 is static:
  const
    YDB_ERR_LOADEOF* = -150374370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:267:9
else:
  let YDB_ERR_LOADEOF* = -150374370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:267:9
when -150374379 is static:
  const
    YDB_ERR_WILLEXPIRE* = -150374379 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:268:9
else:
  let YDB_ERR_WILLEXPIRE* = -150374379 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:268:9
when -150374386 is static:
  const
    YDB_ERR_LOADEDBG* = -150374386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:269:9
else:
  let YDB_ERR_LOADEDBG* = -150374386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:269:9
when -150374394 is static:
  const
    YDB_ERR_LABELONLY* = -150374394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:270:9
else:
  let YDB_ERR_LABELONLY* = -150374394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:270:9
when -150374402 is static:
  const
    YDB_ERR_MUREORGFAIL* = -150374402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:271:9
else:
  let YDB_ERR_MUREORGFAIL* = -150374402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:271:9
when -150374410 is static:
  const
    YDB_ERR_GVZPREVFAIL* = -150374410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:272:9
else:
  let YDB_ERR_GVZPREVFAIL* = -150374410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:272:9
when -150374418 is static:
  const
    YDB_ERR_MULTFORMPARM* = -150374418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:273:9
else:
  let YDB_ERR_MULTFORMPARM* = -150374418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:273:9
when -150374426 is static:
  const
    YDB_ERR_QUITARGUSE* = -150374426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:274:9
else:
  let YDB_ERR_QUITARGUSE* = -150374426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:274:9
when -150374434 is static:
  const
    YDB_ERR_NAMEEXPECTED* = -150374434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:275:9
else:
  let YDB_ERR_NAMEEXPECTED* = -150374434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:275:9
when -150374442 is static:
  const
    YDB_ERR_FALLINTOFLST* = -150374442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:276:9
else:
  let YDB_ERR_FALLINTOFLST* = -150374442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:276:9
when -150374450 is static:
  const
    YDB_ERR_NOTEXTRINSIC* = -150374450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:277:9
else:
  let YDB_ERR_NOTEXTRINSIC* = -150374450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:277:9
when -150374456 is static:
  const
    YDB_ERR_GTMSECSHRREMSEMFAIL* = -150374456 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:278:9
else:
  let YDB_ERR_GTMSECSHRREMSEMFAIL* = -150374456 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:278:9
when -150374466 is static:
  const
    YDB_ERR_FMLLSTMISSING* = -150374466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:279:9
else:
  let YDB_ERR_FMLLSTMISSING* = -150374466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:279:9
when -150374474 is static:
  const
    YDB_ERR_ACTLSTTOOLONG* = -150374474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:280:9
else:
  let YDB_ERR_ACTLSTTOOLONG* = -150374474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:280:9
when -150374482 is static:
  const
    YDB_ERR_ACTOFFSET* = -150374482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:281:9
else:
  let YDB_ERR_ACTOFFSET* = -150374482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:281:9
when -150374490 is static:
  const
    YDB_ERR_MAXACTARG* = -150374490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:282:9
else:
  let YDB_ERR_MAXACTARG* = -150374490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:282:9
when -150374499 is static:
  const
    YDB_ERR_GTMSECSHRREMSEM* = -150374499 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:283:9
else:
  let YDB_ERR_GTMSECSHRREMSEM* = -150374499 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:283:9
when -150374506 is static:
  const
    YDB_ERR_JNLTMQUAL2* = -150374506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:284:9
else:
  let YDB_ERR_JNLTMQUAL2* = -150374506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:284:9
when -150374514 is static:
  const
    YDB_ERR_GDINVALID* = -150374514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:285:9
else:
  let YDB_ERR_GDINVALID* = -150374514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:285:9
when -150374524 is static:
  const
    YDB_ERR_ASSERT* = -150374524 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:286:9
else:
  let YDB_ERR_ASSERT* = -150374524 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:286:9
when -150374531 is static:
  const
    YDB_ERR_MUFILRNDWNSUC* = -150374531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:287:9
else:
  let YDB_ERR_MUFILRNDWNSUC* = -150374531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:287:9
when -150374538 is static:
  const
    YDB_ERR_LOADEDSZ* = -150374538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:288:9
else:
  let YDB_ERR_LOADEDSZ* = -150374538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:288:9
when -150374546 is static:
  const
    YDB_ERR_QUITARGLST* = -150374546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:289:9
else:
  let YDB_ERR_QUITARGLST* = -150374546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:289:9
when -150374554 is static:
  const
    YDB_ERR_QUITARGREQD* = -150374554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:290:9
else:
  let YDB_ERR_QUITARGREQD* = -150374554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:290:9
when -150374562 is static:
  const
    YDB_ERR_CRITRESET* = -150374562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:291:9
else:
  let YDB_ERR_CRITRESET* = -150374562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:291:9
when -150374572 is static:
  const
    YDB_ERR_UNKNOWNFOREX* = -150374572 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:292:9
else:
  let YDB_ERR_UNKNOWNFOREX* = -150374572 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:292:9
when -150374578 is static:
  const
    YDB_ERR_FSEXP* = -150374578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:293:9
else:
  let YDB_ERR_FSEXP* = -150374578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:293:9
when -150374586 is static:
  const
    YDB_ERR_WILDCARD* = -150374586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:294:9
else:
  let YDB_ERR_WILDCARD* = -150374586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:294:9
when -150374594 is static:
  const
    YDB_ERR_DIRONLY* = -150374594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:295:9
else:
  let YDB_ERR_DIRONLY* = -150374594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:295:9
when -150374602 is static:
  const
    YDB_ERR_FILEPARSE* = -150374602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:296:9
else:
  let YDB_ERR_FILEPARSE* = -150374602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:296:9
when -150374610 is static:
  const
    YDB_ERR_QUALEXP* = -150374610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:297:9
else:
  let YDB_ERR_QUALEXP* = -150374610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:297:9
when -150374618 is static:
  const
    YDB_ERR_BADQUAL* = -150374618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:298:9
else:
  let YDB_ERR_BADQUAL* = -150374618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:298:9
when -150374626 is static:
  const
    YDB_ERR_QUALVAL* = -150374626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:299:9
else:
  let YDB_ERR_QUALVAL* = -150374626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:299:9
when -150374634 is static:
  const
    YDB_ERR_ZROSYNTAX* = -150374634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:300:9
else:
  let YDB_ERR_ZROSYNTAX* = -150374634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:300:9
when -150374642 is static:
  const
    YDB_ERR_COMPILEQUALS* = -150374642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:301:9
else:
  let YDB_ERR_COMPILEQUALS* = -150374642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:301:9
when -150374650 is static:
  const
    YDB_ERR_ZLNOOBJECT* = -150374650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:302:9
else:
  let YDB_ERR_ZLNOOBJECT* = -150374650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:302:9
when -150374658 is static:
  const
    YDB_ERR_ZLMODULE* = -150374658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:303:9
else:
  let YDB_ERR_ZLMODULE* = -150374658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:303:9
when -150374667 is static:
  const
    YDB_ERR_DBBLEVMX* = -150374667 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:304:9
else:
  let YDB_ERR_DBBLEVMX* = -150374667 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:304:9
when -150374675 is static:
  const
    YDB_ERR_DBBLEVMN* = -150374675 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:305:9
else:
  let YDB_ERR_DBBLEVMN* = -150374675 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:305:9
when -150374682 is static:
  const
    YDB_ERR_DBBSIZMN* = -150374682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:306:9
else:
  let YDB_ERR_DBBSIZMN* = -150374682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:306:9
when -150374690 is static:
  const
    YDB_ERR_DBBSIZMX* = -150374690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:307:9
else:
  let YDB_ERR_DBBSIZMX* = -150374690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:307:9
when -150374698 is static:
  const
    YDB_ERR_DBRSIZMN* = -150374698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:308:9
else:
  let YDB_ERR_DBRSIZMN* = -150374698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:308:9
when -150374706 is static:
  const
    YDB_ERR_DBRSIZMX* = -150374706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:309:9
else:
  let YDB_ERR_DBRSIZMX* = -150374706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:309:9
when -150374714 is static:
  const
    YDB_ERR_DBCMPNZRO* = -150374714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:310:9
else:
  let YDB_ERR_DBCMPNZRO* = -150374714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:310:9
when -150374723 is static:
  const
    YDB_ERR_DBSTARSIZ* = -150374723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:311:9
else:
  let YDB_ERR_DBSTARSIZ* = -150374723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:311:9
when -150374731 is static:
  const
    YDB_ERR_DBSTARCMP* = -150374731 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:312:9
else:
  let YDB_ERR_DBSTARCMP* = -150374731 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:312:9
when -150374739 is static:
  const
    YDB_ERR_DBCMPMX* = -150374739 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:313:9
else:
  let YDB_ERR_DBCMPMX* = -150374739 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:313:9
when -150374746 is static:
  const
    YDB_ERR_DBKEYMX* = -150374746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:314:9
else:
  let YDB_ERR_DBKEYMX* = -150374746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:314:9
when -150374754 is static:
  const
    YDB_ERR_DBKEYMN* = -150374754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:315:9
else:
  let YDB_ERR_DBKEYMN* = -150374754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:315:9
when -150374760 is static:
  const
    YDB_ERR_DBCMPBAD* = -150374760 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:316:9
else:
  let YDB_ERR_DBCMPBAD* = -150374760 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:316:9
when -150374770 is static:
  const
    YDB_ERR_DBKEYORD* = -150374770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:317:9
else:
  let YDB_ERR_DBKEYORD* = -150374770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:317:9
when -150374778 is static:
  const
    YDB_ERR_DBPTRNOTPOS* = -150374778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:318:9
else:
  let YDB_ERR_DBPTRNOTPOS* = -150374778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:318:9
when -150374786 is static:
  const
    YDB_ERR_DBPTRMX* = -150374786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:319:9
else:
  let YDB_ERR_DBPTRMX* = -150374786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:319:9
when -150374795 is static:
  const
    YDB_ERR_DBPTRMAP* = -150374795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:320:9
else:
  let YDB_ERR_DBPTRMAP* = -150374795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:320:9
when -150374802 is static:
  const
    YDB_ERR_IFBADPARM* = -150374802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:321:9
else:
  let YDB_ERR_IFBADPARM* = -150374802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:321:9
when -150374810 is static:
  const
    YDB_ERR_IFNOTINIT* = -150374810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:322:9
else:
  let YDB_ERR_IFNOTINIT* = -150374810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:322:9
when -150374818 is static:
  const
    YDB_ERR_GTMSECSHRSOCKET* = -150374818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:323:9
else:
  let YDB_ERR_GTMSECSHRSOCKET* = -150374818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:323:9
when -150374826 is static:
  const
    YDB_ERR_LOADBGSZ* = -150374826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:324:9
else:
  let YDB_ERR_LOADBGSZ* = -150374826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:324:9
when -150374834 is static:
  const
    YDB_ERR_LOADFMT* = -150374834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:325:9
else:
  let YDB_ERR_LOADFMT* = -150374834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:325:9
when -150374842 is static:
  const
    YDB_ERR_LOADFILERR* = -150374842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:326:9
else:
  let YDB_ERR_LOADFILERR* = -150374842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:326:9
when -150374850 is static:
  const
    YDB_ERR_NOREGION* = -150374850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:327:9
else:
  let YDB_ERR_NOREGION* = -150374850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:327:9
when -150374858 is static:
  const
    YDB_ERR_PATLOAD* = -150374858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:328:9
else:
  let YDB_ERR_PATLOAD* = -150374858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:328:9
when -150374866 is static:
  const
    YDB_ERR_EXTRACTFILERR* = -150374866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:329:9
else:
  let YDB_ERR_EXTRACTFILERR* = -150374866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:329:9
when -150374875 is static:
  const
    YDB_ERR_FREEZE* = -150374875 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:330:9
else:
  let YDB_ERR_FREEZE* = -150374875 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:330:9
when -150374880 is static:
  const
    YDB_ERR_NOSELECT* = -150374880 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:331:9
else:
  let YDB_ERR_NOSELECT* = -150374880 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:331:9
when -150374890 is static:
  const
    YDB_ERR_EXTRFAIL* = -150374890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:332:9
else:
  let YDB_ERR_EXTRFAIL* = -150374890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:332:9
when -150374898 is static:
  const
    YDB_ERR_LDBINFMT* = -150374898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:333:9
else:
  let YDB_ERR_LDBINFMT* = -150374898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:333:9
when -150374906 is static:
  const
    YDB_ERR_NOPREVLINK* = -150374906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:334:9
else:
  let YDB_ERR_NOPREVLINK* = -150374906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:334:9
when -150374916 is static:
  const
    YDB_ERR_UNUSEDMSG503* = -150374916 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:335:9
else:
  let YDB_ERR_UNUSEDMSG503* = -150374916 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:335:9
when -150374922 is static:
  const
    YDB_ERR_UNUSEDMSG504* = -150374922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:336:9
else:
  let YDB_ERR_UNUSEDMSG504* = -150374922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:336:9
when -150374931 is static:
  const
    YDB_ERR_UNUSEDMSG505* = -150374931 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:337:9
else:
  let YDB_ERR_UNUSEDMSG505* = -150374931 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:337:9
when -150374939 is static:
  const
    YDB_ERR_UNUSEDMSG506* = -150374939 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:338:9
else:
  let YDB_ERR_UNUSEDMSG506* = -150374939 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:338:9
when -150374946 is static:
  const
    YDB_ERR_UNUSEDMSG507* = -150374946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:339:9
else:
  let YDB_ERR_UNUSEDMSG507* = -150374946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:339:9
when -150374954 is static:
  const
    YDB_ERR_REQRUNDOWN* = -150374954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:340:9
else:
  let YDB_ERR_REQRUNDOWN* = -150374954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:340:9
when -150374962 is static:
  const
    YDB_ERR_UNUSEDMSG509* = -150374962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:341:9
else:
  let YDB_ERR_UNUSEDMSG509* = -150374962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:341:9
when -150374970 is static:
  const
    YDB_ERR_UNUSEDMSG510* = -150374970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:342:9
else:
  let YDB_ERR_UNUSEDMSG510* = -150374970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:342:9
when -150374978 is static:
  const
    YDB_ERR_CNOTONSYS* = -150374978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:343:9
else:
  let YDB_ERR_CNOTONSYS* = -150374978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:343:9
when -150374988 is static:
  const
    YDB_ERR_UNUSEDMSG512* = -150374988 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:344:9
else:
  let YDB_ERR_UNUSEDMSG512* = -150374988 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:344:9
when -150374994 is static:
  const
    YDB_ERR_UNUSEDMSG513* = -150374994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:345:9
else:
  let YDB_ERR_UNUSEDMSG513* = -150374994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:345:9
when -150375003 is static:
  const
    YDB_ERR_OPRCCPSTOP* = -150375003 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:346:9
else:
  let YDB_ERR_OPRCCPSTOP* = -150375003 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:346:9
when -150375012 is static:
  const
    YDB_ERR_SELECTSYNTAX* = -150375012 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:347:9
else:
  let YDB_ERR_SELECTSYNTAX* = -150375012 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:347:9
when -150375018 is static:
  const
    YDB_ERR_LOADABORT* = -150375018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:348:9
else:
  let YDB_ERR_LOADABORT* = -150375018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:348:9
when -150375026 is static:
  const
    YDB_ERR_FNOTONSYS* = -150375026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:349:9
else:
  let YDB_ERR_FNOTONSYS* = -150375026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:349:9
when -150375034 is static:
  const
    YDB_ERR_AMBISYIPARAM* = -150375034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:350:9
else:
  let YDB_ERR_AMBISYIPARAM* = -150375034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:350:9
when -150375042 is static:
  const
    YDB_ERR_PREVJNLNOEOF* = -150375042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:351:9
else:
  let YDB_ERR_PREVJNLNOEOF* = -150375042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:351:9
when -150375050 is static:
  const
    YDB_ERR_LKSECINIT* = -150375050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:352:9
else:
  let YDB_ERR_LKSECINIT* = -150375050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:352:9
when -150375059 is static:
  const
    YDB_ERR_BACKUPREPL* = -150375059 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:353:9
else:
  let YDB_ERR_BACKUPREPL* = -150375059 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:353:9
when -150375067 is static:
  const
    YDB_ERR_BACKUPSEQNO* = -150375067 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:354:9
else:
  let YDB_ERR_BACKUPSEQNO* = -150375067 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:354:9
when -150375074 is static:
  const
    YDB_ERR_DIRACCESS* = -150375074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:355:9
else:
  let YDB_ERR_DIRACCESS* = -150375074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:355:9
when -150375082 is static:
  const
    YDB_ERR_TXTSRCMAT* = -150375082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:356:9
else:
  let YDB_ERR_TXTSRCMAT* = -150375082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:356:9
when -150375088 is static:
  const
    YDB_ERR_UNUSEDMSG525* = -150375088 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:357:9
else:
  let YDB_ERR_UNUSEDMSG525* = -150375088 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:357:9
when -150375098 is static:
  const
    YDB_ERR_BADDBVER* = -150375098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:358:9
else:
  let YDB_ERR_BADDBVER* = -150375098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:358:9
when -150375108 is static:
  const
    YDB_ERR_LINKVERSION* = -150375108 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:359:9
else:
  let YDB_ERR_LINKVERSION* = -150375108 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:359:9
when -150375114 is static:
  const
    YDB_ERR_TOTALBLKMAX* = -150375114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:360:9
else:
  let YDB_ERR_TOTALBLKMAX* = -150375114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:360:9
when -150375123 is static:
  const
    YDB_ERR_LOADCTRLY* = -150375123 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:361:9
else:
  let YDB_ERR_LOADCTRLY* = -150375123 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:361:9
when -150375130 is static:
  const
    YDB_ERR_CLSTCONFLICT* = -150375130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:362:9
else:
  let YDB_ERR_CLSTCONFLICT* = -150375130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:362:9
when -150375139 is static:
  const
    YDB_ERR_SRCNAM* = -150375139 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:363:9
else:
  let YDB_ERR_SRCNAM* = -150375139 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:363:9
when -150375145 is static:
  const
    YDB_ERR_LCKGONE* = -150375145 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:364:9
else:
  let YDB_ERR_LCKGONE* = -150375145 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:364:9
when -150375154 is static:
  const
    YDB_ERR_SUB2LONG* = -150375154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:365:9
else:
  let YDB_ERR_SUB2LONG* = -150375154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:365:9
when -150375163 is static:
  const
    YDB_ERR_EXTRACTCTRLY* = -150375163 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:366:9
else:
  let YDB_ERR_EXTRACTCTRLY* = -150375163 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:366:9
when -150375168 is static:
  const
    YDB_ERR_UNUSEDMSG535* = -150375168 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:367:9
else:
  let YDB_ERR_UNUSEDMSG535* = -150375168 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:367:9
when -150375178 is static:
  const
    YDB_ERR_GVQUERYFAIL* = -150375178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:368:9
else:
  let YDB_ERR_GVQUERYFAIL* = -150375178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:368:9
when -150375186 is static:
  const
    YDB_ERR_LCKSCANCELLED* = -150375186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:369:9
else:
  let YDB_ERR_LCKSCANCELLED* = -150375186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:369:9
when -150375194 is static:
  const
    YDB_ERR_INVNETFILNM* = -150375194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:370:9
else:
  let YDB_ERR_INVNETFILNM* = -150375194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:370:9
when -150375202 is static:
  const
    YDB_ERR_NETDBOPNERR* = -150375202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:371:9
else:
  let YDB_ERR_NETDBOPNERR* = -150375202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:371:9
when -150375210 is static:
  const
    YDB_ERR_BADSRVRNETMSG* = -150375210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:372:9
else:
  let YDB_ERR_BADSRVRNETMSG* = -150375210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:372:9
when -150375218 is static:
  const
    YDB_ERR_BADGTMNETMSG* = -150375218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:373:9
else:
  let YDB_ERR_BADGTMNETMSG* = -150375218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:373:9
when -150375226 is static:
  const
    YDB_ERR_SERVERERR* = -150375226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:374:9
else:
  let YDB_ERR_SERVERERR* = -150375226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:374:9
when -150375234 is static:
  const
    YDB_ERR_NETFAIL* = -150375234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:375:9
else:
  let YDB_ERR_NETFAIL* = -150375234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:375:9
when -150375242 is static:
  const
    YDB_ERR_NETLCKFAIL* = -150375242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:376:9
else:
  let YDB_ERR_NETLCKFAIL* = -150375242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:376:9
when -150375251 is static:
  const
    YDB_ERR_TTINVFILTER* = -150375251 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:377:9
else:
  let YDB_ERR_TTINVFILTER* = -150375251 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:377:9
when -150375259 is static:
  const
    YDB_ERR_BACKUPTN* = -150375259 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:378:9
else:
  let YDB_ERR_BACKUPTN* = -150375259 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:378:9
when -150375266 is static:
  const
    YDB_ERR_WCSFLUFAIL* = -150375266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:379:9
else:
  let YDB_ERR_WCSFLUFAIL* = -150375266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:379:9
when -150375274 is static:
  const
    YDB_ERR_BADTRNPARAM* = -150375274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:380:9
else:
  let YDB_ERR_BADTRNPARAM* = -150375274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:380:9
when -150375280 is static:
  const
    YDB_ERR_DSEONLYBGMM* = -150375280 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:381:9
else:
  let YDB_ERR_DSEONLYBGMM* = -150375280 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:381:9
when -150375288 is static:
  const
    YDB_ERR_DSEINVLCLUSFN* = -150375288 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:382:9
else:
  let YDB_ERR_DSEINVLCLUSFN* = -150375288 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:382:9
when -150375298 is static:
  const
    YDB_ERR_RDFLTOOSHORT* = -150375298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:383:9
else:
  let YDB_ERR_RDFLTOOSHORT* = -150375298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:383:9
when -150375307 is static:
  const
    YDB_ERR_TIMRBADVAL* = -150375307 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:384:9
else:
  let YDB_ERR_TIMRBADVAL* = -150375307 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:384:9
when -150375312 is static:
  const
    YDB_ERR_UNUSEDMSG553* = -150375312 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:385:9
else:
  let YDB_ERR_UNUSEDMSG553* = -150375312 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:385:9
when -150375324 is static:
  const
    YDB_ERR_UNUSEDMSG554* = -150375324 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:386:9
else:
  let YDB_ERR_UNUSEDMSG554* = -150375324 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:386:9
when -150375330 is static:
  const
    YDB_ERR_UNSOLCNTERR* = -150375330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:387:9
else:
  let YDB_ERR_UNSOLCNTERR* = -150375330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:387:9
when -150375339 is static:
  const
    YDB_ERR_BACKUPCTRL* = -150375339 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:388:9
else:
  let YDB_ERR_BACKUPCTRL* = -150375339 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:388:9
when -150375346 is static:
  const
    YDB_ERR_NOCCPPID* = -150375346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:389:9
else:
  let YDB_ERR_NOCCPPID* = -150375346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:389:9
when -150375354 is static:
  const
    YDB_ERR_UNUSEDMSG558* = -150375354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:390:9
else:
  let YDB_ERR_UNUSEDMSG558* = -150375354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:390:9
when -150375361 is static:
  const
    YDB_ERR_LCKSGONE* = -150375361 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:391:9
else:
  let YDB_ERR_LCKSGONE* = -150375361 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:391:9
when -150375370 is static:
  const
    YDB_ERR_UNUSEDMSG560* = -150375370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:392:9
else:
  let YDB_ERR_UNUSEDMSG560* = -150375370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:392:9
when -150375378 is static:
  const
    YDB_ERR_DBFILOPERR* = -150375378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:393:9
else:
  let YDB_ERR_DBFILOPERR* = -150375378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:393:9
when -150375386 is static:
  const
    YDB_ERR_UNUSEDMSG562* = -150375386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:394:9
else:
  let YDB_ERR_UNUSEDMSG562* = -150375386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:394:9
when -150375395 is static:
  const
    YDB_ERR_UNUSEDMSG563* = -150375395 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:395:9
else:
  let YDB_ERR_UNUSEDMSG563* = -150375395 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:395:9
when -150375403 is static:
  const
    YDB_ERR_UNUSEDMSG564* = -150375403 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:396:9
else:
  let YDB_ERR_UNUSEDMSG564* = -150375403 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:396:9
when -150375410 is static:
  const
    YDB_ERR_UNUSEDMSG565* = -150375410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:397:9
else:
  let YDB_ERR_UNUSEDMSG565* = -150375410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:397:9
when -150375418 is static:
  const
    YDB_ERR_UNUSEDMSG566* = -150375418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:398:9
else:
  let YDB_ERR_UNUSEDMSG566* = -150375418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:398:9
when -150375426 is static:
  const
    YDB_ERR_UNUSEDMSG567* = -150375426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:399:9
else:
  let YDB_ERR_UNUSEDMSG567* = -150375426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:399:9
when -150375435 is static:
  const
    YDB_ERR_UNUSEDMSG568* = -150375435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:400:9
else:
  let YDB_ERR_UNUSEDMSG568* = -150375435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:400:9
when -150375442 is static:
  const
    YDB_ERR_UNUSEDMSG569* = -150375442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:401:9
else:
  let YDB_ERR_UNUSEDMSG569* = -150375442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:401:9
when -150375451 is static:
  const
    YDB_ERR_UNUSEDMSG570* = -150375451 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:402:9
else:
  let YDB_ERR_UNUSEDMSG570* = -150375451 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:402:9
when -150375459 is static:
  const
    YDB_ERR_UNUSEDMSG571* = -150375459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:403:9
else:
  let YDB_ERR_UNUSEDMSG571* = -150375459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:403:9
when -150375467 is static:
  const
    YDB_ERR_UNUSEDMSG572* = -150375467 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:404:9
else:
  let YDB_ERR_UNUSEDMSG572* = -150375467 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:404:9
when -150375474 is static:
  const
    YDB_ERR_ZSHOWBADFUNC* = -150375474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:405:9
else:
  let YDB_ERR_ZSHOWBADFUNC* = -150375474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:405:9
when -150375480 is static:
  const
    YDB_ERR_NOTALLJNLEN* = -150375480 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:406:9
else:
  let YDB_ERR_NOTALLJNLEN* = -150375480 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:406:9
when -150375490 is static:
  const
    YDB_ERR_BADLOCKNEST* = -150375490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:407:9
else:
  let YDB_ERR_BADLOCKNEST* = -150375490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:407:9
when -150375498 is static:
  const
    YDB_ERR_NOLBRSRC* = -150375498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:408:9
else:
  let YDB_ERR_NOLBRSRC* = -150375498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:408:9
when -150375506 is static:
  const
    YDB_ERR_INVZSTEP* = -150375506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:409:9
else:
  let YDB_ERR_INVZSTEP* = -150375506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:409:9
when -150375514 is static:
  const
    YDB_ERR_ZSTEPARG* = -150375514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:410:9
else:
  let YDB_ERR_ZSTEPARG* = -150375514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:410:9
when -150375522 is static:
  const
    YDB_ERR_INVSTRLEN* = -150375522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:411:9
else:
  let YDB_ERR_INVSTRLEN* = -150375522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:411:9
when -150375531 is static:
  const
    YDB_ERR_RECCNT* = -150375531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:412:9
else:
  let YDB_ERR_RECCNT* = -150375531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:412:9
when -150375539 is static:
  const
    YDB_ERR_TEXT* = -150375539 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:413:9
else:
  let YDB_ERR_TEXT* = -150375539 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:413:9
when -150375546 is static:
  const
    YDB_ERR_ZWRSPONE* = -150375546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:414:9
else:
  let YDB_ERR_ZWRSPONE* = -150375546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:414:9
when -150375555 is static:
  const
    YDB_ERR_FILEDEL* = -150375555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:415:9
else:
  let YDB_ERR_FILEDEL* = -150375555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:415:9
when -150375562 is static:
  const
    YDB_ERR_JNLBADLABEL* = -150375562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:416:9
else:
  let YDB_ERR_JNLBADLABEL* = -150375562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:416:9
when -150375570 is static:
  const
    YDB_ERR_JNLREADEOF* = -150375570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:417:9
else:
  let YDB_ERR_JNLREADEOF* = -150375570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:417:9
when -150375578 is static:
  const
    YDB_ERR_JNLRECFMT* = -150375578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:418:9
else:
  let YDB_ERR_JNLRECFMT* = -150375578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:418:9
when -150375584 is static:
  const
    YDB_ERR_BLKTOODEEP* = -150375584 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:419:9
else:
  let YDB_ERR_BLKTOODEEP* = -150375584 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:419:9
when -150375594 is static:
  const
    YDB_ERR_NESTFORMP* = -150375594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:420:9
else:
  let YDB_ERR_NESTFORMP* = -150375594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:420:9
when -150375602 is static:
  const
    YDB_ERR_UNUSEDMSG589* = -150375602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:421:9
else:
  let YDB_ERR_UNUSEDMSG589* = -150375602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:421:9
when -150375611 is static:
  const
    YDB_ERR_GOQPREC* = -150375611 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:422:9
else:
  let YDB_ERR_GOQPREC* = -150375611 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:422:9
when -150375618 is static:
  const
    YDB_ERR_LDGOQFMT* = -150375618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:423:9
else:
  let YDB_ERR_LDGOQFMT* = -150375618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:423:9
when -150375627 is static:
  const
    YDB_ERR_BEGINST* = -150375627 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:424:9
else:
  let YDB_ERR_BEGINST* = -150375627 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:424:9
when -150375636 is static:
  const
    YDB_ERR_INVMVXSZ* = -150375636 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:425:9
else:
  let YDB_ERR_INVMVXSZ* = -150375636 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:425:9
when -150375642 is static:
  const
    YDB_ERR_JNLWRTNOWWRTR* = -150375642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:426:9
else:
  let YDB_ERR_JNLWRTNOWWRTR* = -150375642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:426:9
when -150375648 is static:
  const
    YDB_ERR_GTMSECSHRSHMCONCPROC* = -150375648 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:427:9
else:
  let YDB_ERR_GTMSECSHRSHMCONCPROC* = -150375648 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:427:9
when -150375656 is static:
  const
    YDB_ERR_JNLINVALLOC* = -150375656 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:428:9
else:
  let YDB_ERR_JNLINVALLOC* = -150375656 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:428:9
when -150375664 is static:
  const
    YDB_ERR_JNLINVEXT* = -150375664 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:429:9
else:
  let YDB_ERR_JNLINVEXT* = -150375664 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:429:9
when -150375674 is static:
  const
    YDB_ERR_MUPCLIERR* = -150375674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:430:9
else:
  let YDB_ERR_MUPCLIERR* = -150375674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:430:9
when -150375682 is static:
  const
    YDB_ERR_JNLTMQUAL4* = -150375682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:431:9
else:
  let YDB_ERR_JNLTMQUAL4* = -150375682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:431:9
when -150375691 is static:
  const
    YDB_ERR_GTMSECSHRREMSHM* = -150375691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:432:9
else:
  let YDB_ERR_GTMSECSHRREMSHM* = -150375691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:432:9
when -150375699 is static:
  const
    YDB_ERR_GTMSECSHRREMFILE* = -150375699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:433:9
else:
  let YDB_ERR_GTMSECSHRREMFILE* = -150375699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:433:9
when -150375706 is static:
  const
    YDB_ERR_MUNODBNAME* = -150375706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:434:9
else:
  let YDB_ERR_MUNODBNAME* = -150375706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:434:9
when -150375715 is static:
  const
    YDB_ERR_FILECREATE* = -150375715 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:435:9
else:
  let YDB_ERR_FILECREATE* = -150375715 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:435:9
when -150375723 is static:
  const
    YDB_ERR_FILENOTCREATE* = -150375723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:436:9
else:
  let YDB_ERR_FILENOTCREATE* = -150375723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:436:9
when -150375728 is static:
  const
    YDB_ERR_JNLPROCSTUCK* = -150375728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:437:9
else:
  let YDB_ERR_JNLPROCSTUCK* = -150375728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:437:9
when -150375738 is static:
  const
    YDB_ERR_INVGLOBALQUAL* = -150375738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:438:9
else:
  let YDB_ERR_INVGLOBALQUAL* = -150375738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:438:9
when -150375746 is static:
  const
    YDB_ERR_COLLARGLONG* = -150375746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:439:9
else:
  let YDB_ERR_COLLARGLONG* = -150375746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:439:9
when -150375754 is static:
  const
    YDB_ERR_NOPINI* = -150375754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:440:9
else:
  let YDB_ERR_NOPINI* = -150375754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:440:9
when -150375762 is static:
  const
    YDB_ERR_DBNOCRE* = -150375762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:441:9
else:
  let YDB_ERR_DBNOCRE* = -150375762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:441:9
when -150375771 is static:
  const
    YDB_ERR_JNLSPACELOW* = -150375771 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:442:9
else:
  let YDB_ERR_JNLSPACELOW* = -150375771 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:442:9
when -150375779 is static:
  const
    YDB_ERR_DBCOMMITCLNUP* = -150375779 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:443:9
else:
  let YDB_ERR_DBCOMMITCLNUP* = -150375779 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:443:9
when -150375786 is static:
  const
    YDB_ERR_BFRQUALREQ* = -150375786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:444:9
else:
  let YDB_ERR_BFRQUALREQ* = -150375786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:444:9
when -150375794 is static:
  const
    YDB_ERR_REQDVIEWPARM* = -150375794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:445:9
else:
  let YDB_ERR_REQDVIEWPARM* = -150375794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:445:9
when -150375802 is static:
  const
    YDB_ERR_COLLFNMISSING* = -150375802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:446:9
else:
  let YDB_ERR_COLLFNMISSING* = -150375802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:446:9
when -150375808 is static:
  const
    YDB_ERR_JNLACTINCMPLT* = -150375808 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:447:9
else:
  let YDB_ERR_JNLACTINCMPLT* = -150375808 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:447:9
when -150375818 is static:
  const
    YDB_ERR_NCTCOLLDIFF* = -150375818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:448:9
else:
  let YDB_ERR_NCTCOLLDIFF* = -150375818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:448:9
when -150375826 is static:
  const
    YDB_ERR_DLRCUNXEOR* = -150375826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:449:9
else:
  let YDB_ERR_DLRCUNXEOR* = -150375826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:449:9
when -150375834 is static:
  const
    YDB_ERR_DLRCTOOBIG* = -150375834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:450:9
else:
  let YDB_ERR_DLRCTOOBIG* = -150375834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:450:9
when -150375842 is static:
  const
    YDB_ERR_WCERRNOTCHG* = -150375842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:451:9
else:
  let YDB_ERR_WCERRNOTCHG* = -150375842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:451:9
when -150375848 is static:
  const
    YDB_ERR_WCWRNNOTCHG* = -150375848 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:452:9
else:
  let YDB_ERR_WCWRNNOTCHG* = -150375848 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:452:9
when -150375858 is static:
  const
    YDB_ERR_ZCWRONGDESC* = -150375858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:453:9
else:
  let YDB_ERR_ZCWRONGDESC* = -150375858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:453:9
when -150375864 is static:
  const
    YDB_ERR_MUTNWARN* = -150375864 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:454:9
else:
  let YDB_ERR_MUTNWARN* = -150375864 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:454:9
when -150375875 is static:
  const
    YDB_ERR_GTMSECSHRUPDDBHDR* = -150375875 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:455:9
else:
  let YDB_ERR_GTMSECSHRUPDDBHDR* = -150375875 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:455:9
when -150375880 is static:
  const
    YDB_ERR_LCKSTIMOUT* = -150375880 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:456:9
else:
  let YDB_ERR_LCKSTIMOUT* = -150375880 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:456:9
when -150375890 is static:
  const
    YDB_ERR_CTLMNEMAXLEN* = -150375890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:457:9
else:
  let YDB_ERR_CTLMNEMAXLEN* = -150375890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:457:9
when -150375898 is static:
  const
    YDB_ERR_CTLMNEXPECTED* = -150375898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:458:9
else:
  let YDB_ERR_CTLMNEXPECTED* = -150375898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:458:9
when -150375906 is static:
  const
    YDB_ERR_USRIOINIT* = -150375906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:459:9
else:
  let YDB_ERR_USRIOINIT* = -150375906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:459:9
when -150375914 is static:
  const
    YDB_ERR_CRITSEMFAIL* = -150375914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:460:9
else:
  let YDB_ERR_CRITSEMFAIL* = -150375914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:460:9
when -150375922 is static:
  const
    YDB_ERR_TERMWRITE* = -150375922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:461:9
else:
  let YDB_ERR_TERMWRITE* = -150375922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:461:9
when -150375930 is static:
  const
    YDB_ERR_COLLTYPVERSION* = -150375930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:462:9
else:
  let YDB_ERR_COLLTYPVERSION* = -150375930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:462:9
when -150375938 is static:
  const
    YDB_ERR_LVNULLSUBS* = -150375938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:463:9
else:
  let YDB_ERR_LVNULLSUBS* = -150375938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:463:9
when -150375946 is static:
  const
    YDB_ERR_GVREPLERR* = -150375946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:464:9
else:
  let YDB_ERR_GVREPLERR* = -150375946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:464:9
when -150375954 is static:
  const
    YDB_ERR_UNUSEDMSG633* = -150375954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:465:9
else:
  let YDB_ERR_UNUSEDMSG633* = -150375954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:465:9
when -150375962 is static:
  const
    YDB_ERR_RMWIDTHPOS* = -150375962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:466:9
else:
  let YDB_ERR_RMWIDTHPOS* = -150375962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:466:9
when -150375970 is static:
  const
    YDB_ERR_OFFSETINV* = -150375970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:467:9
else:
  let YDB_ERR_OFFSETINV* = -150375970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:467:9
when -150375978 is static:
  const
    YDB_ERR_JOBPARTOOLONG* = -150375978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:468:9
else:
  let YDB_ERR_JOBPARTOOLONG* = -150375978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:468:9
when -150375987 is static:
  const
    YDB_ERR_RLNKINTEGINFO* = -150375987 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:469:9
else:
  let YDB_ERR_RLNKINTEGINFO* = -150375987 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:469:9
when -150375994 is static:
  const
    YDB_ERR_RUNPARAMERR* = -150375994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:470:9
else:
  let YDB_ERR_RUNPARAMERR* = -150375994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:470:9
when -150376002 is static:
  const
    YDB_ERR_FNNAMENEG* = -150376002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:471:9
else:
  let YDB_ERR_FNNAMENEG* = -150376002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:471:9
when -150376010 is static:
  const
    YDB_ERR_ORDER2* = -150376010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:472:9
else:
  let YDB_ERR_ORDER2* = -150376010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:472:9
when -150376018 is static:
  const
    YDB_ERR_MUNOUPGRD* = -150376018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:473:9
else:
  let YDB_ERR_MUNOUPGRD* = -150376018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:473:9
when -150376027 is static:
  const
    YDB_ERR_REORGCTRLY* = -150376027 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:474:9
else:
  let YDB_ERR_REORGCTRLY* = -150376027 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:474:9
when -150376034 is static:
  const
    YDB_ERR_TSTRTPARM* = -150376034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:475:9
else:
  let YDB_ERR_TSTRTPARM* = -150376034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:475:9
when -150376042 is static:
  const
    YDB_ERR_TRIGNAMENF* = -150376042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:476:9
else:
  let YDB_ERR_TRIGNAMENF* = -150376042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:476:9
when -150376048 is static:
  const
    YDB_ERR_TRIGZBREAKREM* = -150376048 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:477:9
else:
  let YDB_ERR_TRIGZBREAKREM* = -150376048 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:477:9
when -150376058 is static:
  const
    YDB_ERR_TLVLZERO* = -150376058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:478:9
else:
  let YDB_ERR_TLVLZERO* = -150376058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:478:9
when -150376066 is static:
  const
    YDB_ERR_TRESTNOT* = -150376066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:479:9
else:
  let YDB_ERR_TRESTNOT* = -150376066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:479:9
when -150376074 is static:
  const
    YDB_ERR_TPLOCK* = -150376074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:480:9
else:
  let YDB_ERR_TPLOCK* = -150376074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:480:9
when -150376082 is static:
  const
    YDB_ERR_TPQUIT* = -150376082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:481:9
else:
  let YDB_ERR_TPQUIT* = -150376082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:481:9
when -150376090 is static:
  const
    YDB_ERR_TPFAIL* = -150376090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:482:9
else:
  let YDB_ERR_TPFAIL* = -150376090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:482:9
when -150376098 is static:
  const
    YDB_ERR_TPRETRY* = -150376098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:483:9
else:
  let YDB_ERR_TPRETRY* = -150376098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:483:9
when -150376106 is static:
  const
    YDB_ERR_TPTOODEEP* = -150376106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:484:9
else:
  let YDB_ERR_TPTOODEEP* = -150376106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:484:9
when -150376114 is static:
  const
    YDB_ERR_ZDEFACTIVE* = -150376114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:485:9
else:
  let YDB_ERR_ZDEFACTIVE* = -150376114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:485:9
when -150376122 is static:
  const
    YDB_ERR_ZDEFOFLOW* = -150376122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:486:9
else:
  let YDB_ERR_ZDEFOFLOW* = -150376122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:486:9
when -150376130 is static:
  const
    YDB_ERR_MUPRESTERR* = -150376130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:487:9
else:
  let YDB_ERR_MUPRESTERR* = -150376130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:487:9
when -150376138 is static:
  const
    YDB_ERR_MUBCKNODIR* = -150376138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:488:9
else:
  let YDB_ERR_MUBCKNODIR* = -150376138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:488:9
when -150376146 is static:
  const
    YDB_ERR_TRANS2BIG* = -150376146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:489:9
else:
  let YDB_ERR_TRANS2BIG* = -150376146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:489:9
when -150376154 is static:
  const
    YDB_ERR_INVBITLEN* = -150376154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:490:9
else:
  let YDB_ERR_INVBITLEN* = -150376154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:490:9
when -150376162 is static:
  const
    YDB_ERR_INVBITSTR* = -150376162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:491:9
else:
  let YDB_ERR_INVBITSTR* = -150376162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:491:9
when -150376170 is static:
  const
    YDB_ERR_INVBITPOS* = -150376170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:492:9
else:
  let YDB_ERR_INVBITPOS* = -150376170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:492:9
when -150376177 is static:
  const
    YDB_ERR_PARNORMAL* = -150376177 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:493:9
else:
  let YDB_ERR_PARNORMAL* = -150376177 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:493:9
when -150376186 is static:
  const
    YDB_ERR_FILEPATHTOOLONG* = -150376186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:494:9
else:
  let YDB_ERR_FILEPATHTOOLONG* = -150376186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:494:9
when -150376194 is static:
  const
    YDB_ERR_RMWIDTHTOOBIG* = -150376194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:495:9
else:
  let YDB_ERR_RMWIDTHTOOBIG* = -150376194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:495:9
when -150376202 is static:
  const
    YDB_ERR_PATTABNOTFND* = -150376202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:496:9
else:
  let YDB_ERR_PATTABNOTFND* = -150376202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:496:9
when -150376210 is static:
  const
    YDB_ERR_OBJFILERR* = -150376210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:497:9
else:
  let YDB_ERR_OBJFILERR* = -150376210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:497:9
when -418811674 is static:
  const
    YDB_ERR_SRCFILERR* = -418811674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:498:9
else:
  let YDB_ERR_SRCFILERR* = -418811674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:498:9
when -150376226 is static:
  const
    YDB_ERR_NEGFRACPWR* = -150376226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:499:9
else:
  let YDB_ERR_NEGFRACPWR* = -150376226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:499:9
when -150376234 is static:
  const
    YDB_ERR_MTNOSKIP* = -150376234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:500:9
else:
  let YDB_ERR_MTNOSKIP* = -150376234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:500:9
when -150376242 is static:
  const
    YDB_ERR_CETOOMANY* = -150376242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:501:9
else:
  let YDB_ERR_CETOOMANY* = -150376242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:501:9
when -150376250 is static:
  const
    YDB_ERR_CEUSRERROR* = -150376250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:502:9
else:
  let YDB_ERR_CEUSRERROR* = -150376250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:502:9
when -150376258 is static:
  const
    YDB_ERR_CEBIGSKIP* = -150376258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:503:9
else:
  let YDB_ERR_CEBIGSKIP* = -150376258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:503:9
when -150376266 is static:
  const
    YDB_ERR_CETOOLONG* = -150376266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:504:9
else:
  let YDB_ERR_CETOOLONG* = -150376266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:504:9
when -150376274 is static:
  const
    YDB_ERR_CENOINDIR* = -150376274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:505:9
else:
  let YDB_ERR_CENOINDIR* = -150376274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:505:9
when -150376282 is static:
  const
    YDB_ERR_COLLATIONUNDEF* = -150376282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:506:9
else:
  let YDB_ERR_COLLATIONUNDEF* = -150376282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:506:9
when -150376290 is static:
  const
    YDB_ERR_MSTACKCRIT* = -150376290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:507:9
else:
  let YDB_ERR_MSTACKCRIT* = -150376290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:507:9
when -150376298 is static:
  const
    YDB_ERR_GTMSECSHRSRVF* = -150376298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:508:9
else:
  let YDB_ERR_GTMSECSHRSRVF* = -150376298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:508:9
when -150376307 is static:
  const
    YDB_ERR_FREEZECTRL* = -150376307 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:509:9
else:
  let YDB_ERR_FREEZECTRL* = -150376307 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:509:9
when -150376315 is static:
  const
    YDB_ERR_JNLFLUSH* = -150376315 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:510:9
else:
  let YDB_ERR_JNLFLUSH* = -150376315 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:510:9
when -150376323 is static:
  const
    YDB_ERR_UNUSEDMSG679* = -150376323 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:511:9
else:
  let YDB_ERR_UNUSEDMSG679* = -150376323 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:511:9
when -150376332 is static:
  const
    YDB_ERR_NOPRINCIO* = -150376332 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:512:9
else:
  let YDB_ERR_NOPRINCIO* = -150376332 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:512:9
when -150376338 is static:
  const
    YDB_ERR_INVPORTSPEC* = -150376338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:513:9
else:
  let YDB_ERR_INVPORTSPEC* = -150376338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:513:9
when -150376346 is static:
  const
    YDB_ERR_INVADDRSPEC* = -150376346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:514:9
else:
  let YDB_ERR_INVADDRSPEC* = -150376346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:514:9
when -150376355 is static:
  const
    YDB_ERR_MUREENCRYPTEND* = -150376355 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:515:9
else:
  let YDB_ERR_MUREENCRYPTEND* = -150376355 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:515:9
when -150376362 is static:
  const
    YDB_ERR_CRYPTJNLMISMATCH* = -150376362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:516:9
else:
  let YDB_ERR_CRYPTJNLMISMATCH* = -150376362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:516:9
when -150376370 is static:
  const
    YDB_ERR_SOCKWAIT* = -150376370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:517:9
else:
  let YDB_ERR_SOCKWAIT* = -150376370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:517:9
when -150376378 is static:
  const
    YDB_ERR_SOCKACPT* = -150376378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:518:9
else:
  let YDB_ERR_SOCKACPT* = -150376378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:518:9
when -150376386 is static:
  const
    YDB_ERR_SOCKINIT* = -150376386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:519:9
else:
  let YDB_ERR_SOCKINIT* = -150376386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:519:9
when -150376394 is static:
  const
    YDB_ERR_OPENCONN* = -150376394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:520:9
else:
  let YDB_ERR_OPENCONN* = -150376394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:520:9
when -150376402 is static:
  const
    YDB_ERR_DEVNOTIMP* = -150376402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:521:9
else:
  let YDB_ERR_DEVNOTIMP* = -150376402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:521:9
when -150376410 is static:
  const
    YDB_ERR_PATALTER2LARGE* = -150376410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:522:9
else:
  let YDB_ERR_PATALTER2LARGE* = -150376410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:522:9
when -150376418 is static:
  const
    YDB_ERR_DBREMOTE* = -150376418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:523:9
else:
  let YDB_ERR_DBREMOTE* = -150376418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:523:9
when -150376426 is static:
  const
    YDB_ERR_JNLREQUIRED* = -150376426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:524:9
else:
  let YDB_ERR_JNLREQUIRED* = -150376426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:524:9
when -150376434 is static:
  const
    YDB_ERR_TPMIXUP* = -150376434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:525:9
else:
  let YDB_ERR_TPMIXUP* = -150376434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:525:9
when -150376442 is static:
  const
    YDB_ERR_HTOFLOW* = -150376442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:526:9
else:
  let YDB_ERR_HTOFLOW* = -150376442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:526:9
when -150376450 is static:
  const
    YDB_ERR_RMNOBIGRECORD* = -150376450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:527:9
else:
  let YDB_ERR_RMNOBIGRECORD* = -150376450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:527:9
when -150376459 is static:
  const
    YDB_ERR_DBBMSIZE* = -150376459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:528:9
else:
  let YDB_ERR_DBBMSIZE* = -150376459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:528:9
when -150376467 is static:
  const
    YDB_ERR_DBBMBARE* = -150376467 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:529:9
else:
  let YDB_ERR_DBBMBARE* = -150376467 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:529:9
when -150376475 is static:
  const
    YDB_ERR_DBBMINV* = -150376475 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:530:9
else:
  let YDB_ERR_DBBMINV* = -150376475 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:530:9
when -150376483 is static:
  const
    YDB_ERR_DBBMMSTR* = -150376483 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:531:9
else:
  let YDB_ERR_DBBMMSTR* = -150376483 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:531:9
when -150376491 is static:
  const
    YDB_ERR_DBROOTBURN* = -150376491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:532:9
else:
  let YDB_ERR_DBROOTBURN* = -150376491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:532:9
when -150376498 is static:
  const
    YDB_ERR_REPLSTATEERR* = -150376498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:533:9
else:
  let YDB_ERR_REPLSTATEERR* = -150376498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:533:9
when -150376506 is static:
  const
    YDB_ERR_UNUSEDMSG702* = -150376506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:534:9
else:
  let YDB_ERR_UNUSEDMSG702* = -150376506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:534:9
when -150376515 is static:
  const
    YDB_ERR_DBDIRTSUBSC* = -150376515 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:535:9
else:
  let YDB_ERR_DBDIRTSUBSC* = -150376515 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:535:9
when -150376522 is static:
  const
    YDB_ERR_TIMEROVFL* = -150376522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:536:9
else:
  let YDB_ERR_TIMEROVFL* = -150376522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:536:9
when -150376532 is static:
  const
    YDB_ERR_GTMASSERT* = -150376532 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:537:9
else:
  let YDB_ERR_GTMASSERT* = -150376532 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:537:9
when -150376539 is static:
  const
    YDB_ERR_DBFHEADERR4* = -150376539 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:538:9
else:
  let YDB_ERR_DBFHEADERR4* = -150376539 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:538:9
when -150376547 is static:
  const
    YDB_ERR_DBADDRANGE* = -150376547 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:539:9
else:
  let YDB_ERR_DBADDRANGE* = -150376547 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:539:9
when -150376555 is static:
  const
    YDB_ERR_DBQUELINK* = -150376555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:540:9
else:
  let YDB_ERR_DBQUELINK* = -150376555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:540:9
when -150376563 is static:
  const
    YDB_ERR_DBCRERR* = -150376563 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:541:9
else:
  let YDB_ERR_DBCRERR* = -150376563 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:541:9
when -150376571 is static:
  const
    YDB_ERR_MUSTANDALONE* = -150376571 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:542:9
else:
  let YDB_ERR_MUSTANDALONE* = -150376571 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:542:9
when -150376578 is static:
  const
    YDB_ERR_MUNOACTION* = -150376578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:543:9
else:
  let YDB_ERR_MUNOACTION* = -150376578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:543:9
when -150376586 is static:
  const
    YDB_ERR_RMBIGSHARE* = -150376586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:544:9
else:
  let YDB_ERR_RMBIGSHARE* = -150376586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:544:9
when -150376595 is static:
  const
    YDB_ERR_TPRESTART* = -150376595 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:545:9
else:
  let YDB_ERR_TPRESTART* = -150376595 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:545:9
when -150376602 is static:
  const
    YDB_ERR_SOCKWRITE* = -150376602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:546:9
else:
  let YDB_ERR_SOCKWRITE* = -150376602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:546:9
when -150376611 is static:
  const
    YDB_ERR_DBCNTRLERR* = -150376611 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:547:9
else:
  let YDB_ERR_DBCNTRLERR* = -150376611 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:547:9
when -150376619 is static:
  const
    YDB_ERR_NOTERMENV* = -150376619 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:548:9
else:
  let YDB_ERR_NOTERMENV* = -150376619 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:548:9
when -150376627 is static:
  const
    YDB_ERR_NOTERMENTRY* = -150376627 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:549:9
else:
  let YDB_ERR_NOTERMENTRY* = -150376627 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:549:9
when -150376635 is static:
  const
    YDB_ERR_NOTERMINFODB* = -150376635 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:550:9
else:
  let YDB_ERR_NOTERMINFODB* = -150376635 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:550:9
when -150376642 is static:
  const
    YDB_ERR_INVACCMETHOD* = -150376642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:551:9
else:
  let YDB_ERR_INVACCMETHOD* = -150376642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:551:9
when -150376650 is static:
  const
    YDB_ERR_JNLOPNERR* = -150376650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:552:9
else:
  let YDB_ERR_JNLOPNERR* = -150376650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:552:9
when -150376658 is static:
  const
    YDB_ERR_JNLRECTYPE* = -150376658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:553:9
else:
  let YDB_ERR_JNLRECTYPE* = -150376658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:553:9
when -150376666 is static:
  const
    YDB_ERR_JNLTRANSGTR* = -150376666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:554:9
else:
  let YDB_ERR_JNLTRANSGTR* = -150376666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:554:9
when -150376674 is static:
  const
    YDB_ERR_JNLTRANSLSS* = -150376674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:555:9
else:
  let YDB_ERR_JNLTRANSLSS* = -150376674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:555:9
when -150376682 is static:
  const
    YDB_ERR_JNLWRERR* = -150376682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:556:9
else:
  let YDB_ERR_JNLWRERR* = -150376682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:556:9
when -150376690 is static:
  const
    YDB_ERR_FILEIDMATCH* = -150376690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:557:9
else:
  let YDB_ERR_FILEIDMATCH* = -150376690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:557:9
when -150376699 is static:
  const
    YDB_ERR_EXTSRCLIN* = -150376699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:558:9
else:
  let YDB_ERR_EXTSRCLIN* = -150376699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:558:9
when -150376707 is static:
  const
    YDB_ERR_EXTSRCLOC* = -150376707 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:559:9
else:
  let YDB_ERR_EXTSRCLOC* = -150376707 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:559:9
when -150376714 is static:
  const
    YDB_ERR_UNUSEDMSG728* = -150376714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:560:9
else:
  let YDB_ERR_UNUSEDMSG728* = -150376714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:560:9
when -150376722 is static:
  const
    YDB_ERR_ERRCALL* = -150376722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:561:9
else:
  let YDB_ERR_ERRCALL* = -150376722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:561:9
when -150376730 is static:
  const
    YDB_ERR_ZCCTENV* = -150376730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:562:9
else:
  let YDB_ERR_ZCCTENV* = -150376730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:562:9
when -418812194 is static:
  const
    YDB_ERR_ZCCTOPN* = -418812194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:563:9
else:
  let YDB_ERR_ZCCTOPN* = -418812194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:563:9
when -150376746 is static:
  const
    YDB_ERR_ZCCTNULLF* = -150376746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:564:9
else:
  let YDB_ERR_ZCCTNULLF* = -150376746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:564:9
when -150376754 is static:
  const
    YDB_ERR_ZCUNAVAIL* = -150376754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:565:9
else:
  let YDB_ERR_ZCUNAVAIL* = -150376754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:565:9
when -150376762 is static:
  const
    YDB_ERR_ZCENTNAME* = -150376762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:566:9
else:
  let YDB_ERR_ZCENTNAME* = -150376762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:566:9
when -150376770 is static:
  const
    YDB_ERR_ZCCOLON* = -150376770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:567:9
else:
  let YDB_ERR_ZCCOLON* = -150376770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:567:9
when -150376778 is static:
  const
    YDB_ERR_ZCRTNTYP* = -150376778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:568:9
else:
  let YDB_ERR_ZCRTNTYP* = -150376778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:568:9
when -150376786 is static:
  const
    YDB_ERR_ZCRCALLNAME* = -150376786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:569:9
else:
  let YDB_ERR_ZCRCALLNAME* = -150376786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:569:9
when -150376794 is static:
  const
    YDB_ERR_ZCRPARMNAME* = -150376794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:570:9
else:
  let YDB_ERR_ZCRPARMNAME* = -150376794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:570:9
when -150376802 is static:
  const
    YDB_ERR_ZCUNTYPE* = -150376802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:571:9
else:
  let YDB_ERR_ZCUNTYPE* = -150376802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:571:9
when -150376810 is static:
  const
    YDB_ERR_UNUSEDMSG740* = -150376810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:572:9
else:
  let YDB_ERR_UNUSEDMSG740* = -150376810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:572:9
when -150376818 is static:
  const
    YDB_ERR_ZCSTATUSRET* = -150376818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:573:9
else:
  let YDB_ERR_ZCSTATUSRET* = -150376818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:573:9
when -150376826 is static:
  const
    YDB_ERR_ZCMAXPARAM* = -150376826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:574:9
else:
  let YDB_ERR_ZCMAXPARAM* = -150376826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:574:9
when -150376834 is static:
  const
    YDB_ERR_ZCCSQRBR* = -150376834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:575:9
else:
  let YDB_ERR_ZCCSQRBR* = -150376834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:575:9
when -150376842 is static:
  const
    YDB_ERR_ZCPREALLNUMEX* = -150376842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:576:9
else:
  let YDB_ERR_ZCPREALLNUMEX* = -150376842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:576:9
when -150376850 is static:
  const
    YDB_ERR_ZCPREALLVALPAR* = -150376850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:577:9
else:
  let YDB_ERR_ZCPREALLVALPAR* = -150376850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:577:9
when -150376858 is static:
  const
    YDB_ERR_VERMISMATCH* = -150376858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:578:9
else:
  let YDB_ERR_VERMISMATCH* = -150376858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:578:9
when -150376866 is static:
  const
    YDB_ERR_JNLCNTRL* = -150376866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:579:9
else:
  let YDB_ERR_JNLCNTRL* = -150376866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:579:9
when -150376874 is static:
  const
    YDB_ERR_TRIGNAMBAD* = -150376874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:580:9
else:
  let YDB_ERR_TRIGNAMBAD* = -150376874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:580:9
when -150376882 is static:
  const
    YDB_ERR_BUFRDTIMEOUT* = -150376882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:581:9
else:
  let YDB_ERR_BUFRDTIMEOUT* = -150376882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:581:9
when -150376890 is static:
  const
    YDB_ERR_INVALIDRIP* = -150376890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:582:9
else:
  let YDB_ERR_INVALIDRIP* = -150376890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:582:9
when -150376899 is static:
  const
    YDB_ERR_BLKSIZ512* = -150376899 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:583:9
else:
  let YDB_ERR_BLKSIZ512* = -150376899 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:583:9
when -150376906 is static:
  const
    YDB_ERR_MUTEXERR* = -150376906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:584:9
else:
  let YDB_ERR_MUTEXERR* = -150376906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:584:9
when -150376914 is static:
  const
    YDB_ERR_JNLVSIZE* = -150376914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:585:9
else:
  let YDB_ERR_JNLVSIZE* = -150376914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:585:9
when -150376920 is static:
  const
    YDB_ERR_MUTEXLCKALERT* = -150376920 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:586:9
else:
  let YDB_ERR_MUTEXLCKALERT* = -150376920 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:586:9
when -150376928 is static:
  const
    YDB_ERR_MUTEXFRCDTERM* = -150376928 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:587:9
else:
  let YDB_ERR_MUTEXFRCDTERM* = -150376928 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:587:9
when -150376938 is static:
  const
    YDB_ERR_GTMSECSHR* = -150376938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:588:9
else:
  let YDB_ERR_GTMSECSHR* = -150376938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:588:9
when -150376944 is static:
  const
    YDB_ERR_GTMSECSHRSRVFID* = -150376944 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:589:9
else:
  let YDB_ERR_GTMSECSHRSRVFID* = -150376944 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:589:9
when -150376952 is static:
  const
    YDB_ERR_GTMSECSHRSRVFIL* = -150376952 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:590:9
else:
  let YDB_ERR_GTMSECSHRSRVFIL* = -150376952 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:590:9
when -150376960 is static:
  const
    YDB_ERR_FREEBLKSLOW* = -150376960 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:591:9
else:
  let YDB_ERR_FREEBLKSLOW* = -150376960 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:591:9
when -150376970 is static:
  const
    YDB_ERR_PROTNOTSUP* = -150376970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:592:9
else:
  let YDB_ERR_PROTNOTSUP* = -150376970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:592:9
when -150376978 is static:
  const
    YDB_ERR_DELIMSIZNA* = -150376978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:593:9
else:
  let YDB_ERR_DELIMSIZNA* = -150376978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:593:9
when -150376986 is static:
  const
    YDB_ERR_INVCTLMNE* = -150376986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:594:9
else:
  let YDB_ERR_INVCTLMNE* = -150376986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:594:9
when -150376994 is static:
  const
    YDB_ERR_SOCKLISTEN* = -150376994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:595:9
else:
  let YDB_ERR_SOCKLISTEN* = -150376994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:595:9
when -150377003 is static:
  const
    YDB_ERR_RESTORESUCCESS* = -150377003 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:596:9
else:
  let YDB_ERR_RESTORESUCCESS* = -150377003 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:596:9
when -150377010 is static:
  const
    YDB_ERR_ADDRTOOLONG* = -150377010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:597:9
else:
  let YDB_ERR_ADDRTOOLONG* = -150377010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:597:9
when -150377016 is static:
  const
    YDB_ERR_GTMSECSHRGETSEMFAIL* = -150377016 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:598:9
else:
  let YDB_ERR_GTMSECSHRGETSEMFAIL* = -150377016 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:598:9
when -150377026 is static:
  const
    YDB_ERR_CPBEYALLOC* = -150377026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:599:9
else:
  let YDB_ERR_CPBEYALLOC* = -150377026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:599:9
when -418812490 is static:
  const
    YDB_ERR_DBRDONLY* = -418812490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:600:9
else:
  let YDB_ERR_DBRDONLY* = -418812490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:600:9
when -150377040 is static:
  const
    YDB_ERR_DUPTN* = -150377040 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:601:9
else:
  let YDB_ERR_DUPTN* = -150377040 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:601:9
when -150377050 is static:
  const
    YDB_ERR_TRESTLOC* = -150377050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:602:9
else:
  let YDB_ERR_TRESTLOC* = -150377050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:602:9
when -150377058 is static:
  const
    YDB_ERR_REPLPOOLINST* = -150377058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:603:9
else:
  let YDB_ERR_REPLPOOLINST* = -150377058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:603:9
when -150377064 is static:
  const
    YDB_ERR_ZCVECTORINDX* = -150377064 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:604:9
else:
  let YDB_ERR_ZCVECTORINDX* = -150377064 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:604:9
when -150377074 is static:
  const
    YDB_ERR_REPLNOTON* = -150377074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:605:9
else:
  let YDB_ERR_REPLNOTON* = -150377074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:605:9
when -150377082 is static:
  const
    YDB_ERR_JNLMOVED* = -150377082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:606:9
else:
  let YDB_ERR_JNLMOVED* = -150377082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:606:9
when -150377090 is static:
  const
    YDB_ERR_EXTRFMT* = -150377090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:607:9
else:
  let YDB_ERR_EXTRFMT* = -150377090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:607:9
when -150377099 is static:
  const
    YDB_ERR_CALLERID* = -150377099 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:608:9
else:
  let YDB_ERR_CALLERID* = -150377099 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:608:9
when -150377108 is static:
  const
    YDB_ERR_KRNLKILL* = -150377108 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:609:9
else:
  let YDB_ERR_KRNLKILL* = -150377108 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:609:9
when -150377116 is static:
  const
    YDB_ERR_MEMORYRECURSIVE* = -150377116 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:610:9
else:
  let YDB_ERR_MEMORYRECURSIVE* = -150377116 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:610:9
when -150377123 is static:
  const
    YDB_ERR_FREEZEID* = -150377123 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:611:9
else:
  let YDB_ERR_FREEZEID* = -150377123 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:611:9
when -150377130 is static:
  const
    YDB_ERR_UNUSEDMSG780* = -150377130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:612:9
else:
  let YDB_ERR_UNUSEDMSG780* = -150377130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:612:9
when -150377138 is static:
  const
    YDB_ERR_DSEINVALBLKID* = -150377138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:613:9
else:
  let YDB_ERR_DSEINVALBLKID* = -150377138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:613:9
when -150377146 is static:
  const
    YDB_ERR_PINENTRYERR* = -150377146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:614:9
else:
  let YDB_ERR_PINENTRYERR* = -150377146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:614:9
when -150377154 is static:
  const
    YDB_ERR_BCKUPBUFLUSH* = -150377154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:615:9
else:
  let YDB_ERR_BCKUPBUFLUSH* = -150377154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:615:9
when -150377160 is static:
  const
    YDB_ERR_NOFORKCORE* = -150377160 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:616:9
else:
  let YDB_ERR_NOFORKCORE* = -150377160 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:616:9
when -150377170 is static:
  const
    YDB_ERR_JNLREAD* = -150377170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:617:9
else:
  let YDB_ERR_JNLREAD* = -150377170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:617:9
when -150377176 is static:
  const
    YDB_ERR_JNLMINALIGN* = -150377176 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:618:9
else:
  let YDB_ERR_JNLMINALIGN* = -150377176 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:618:9
when -150377186 is static:
  const
    YDB_ERR_JOBSTARTCMDFAIL* = -150377186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:619:9
else:
  let YDB_ERR_JOBSTARTCMDFAIL* = -150377186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:619:9
when -150377194 is static:
  const
    YDB_ERR_JNLPOOLSETUP* = -150377194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:620:9
else:
  let YDB_ERR_JNLPOOLSETUP* = -150377194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:620:9
when -150377202 is static:
  const
    YDB_ERR_JNLSTATEOFF* = -150377202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:621:9
else:
  let YDB_ERR_JNLSTATEOFF* = -150377202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:621:9
when -150377210 is static:
  const
    YDB_ERR_RECVPOOLSETUP* = -150377210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:622:9
else:
  let YDB_ERR_RECVPOOLSETUP* = -150377210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:622:9
when -150377218 is static:
  const
    YDB_ERR_REPLCOMM* = -150377218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:623:9
else:
  let YDB_ERR_REPLCOMM* = -150377218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:623:9
when -150377224 is static:
  const
    YDB_ERR_NOREPLCTDREG* = -150377224 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:624:9
else:
  let YDB_ERR_NOREPLCTDREG* = -150377224 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:624:9
when -150377235 is static:
  const
    YDB_ERR_REPLINFO* = -150377235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:625:9
else:
  let YDB_ERR_REPLINFO* = -150377235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:625:9
when -150377240 is static:
  const
    YDB_ERR_REPLWARN* = -150377240 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:626:9
else:
  let YDB_ERR_REPLWARN* = -150377240 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:626:9
when -150377250 is static:
  const
    YDB_ERR_REPLERR* = -150377250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:627:9
else:
  let YDB_ERR_REPLERR* = -150377250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:627:9
when -150377258 is static:
  const
    YDB_ERR_JNLNMBKNOTPRCD* = -150377258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:628:9
else:
  let YDB_ERR_JNLNMBKNOTPRCD* = -150377258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:628:9
when -150377266 is static:
  const
    YDB_ERR_REPLFILIOERR* = -150377266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:629:9
else:
  let YDB_ERR_REPLFILIOERR* = -150377266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:629:9
when -150377274 is static:
  const
    YDB_ERR_REPLBRKNTRANS* = -150377274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:630:9
else:
  let YDB_ERR_REPLBRKNTRANS* = -150377274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:630:9
when -150377282 is static:
  const
    YDB_ERR_TTWIDTHTOOBIG* = -150377282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:631:9
else:
  let YDB_ERR_TTWIDTHTOOBIG* = -150377282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:631:9
when -418812746 is static:
  const
    YDB_ERR_REPLLOGOPN* = -418812746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:632:9
else:
  let YDB_ERR_REPLLOGOPN* = -418812746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:632:9
when -150377298 is static:
  const
    YDB_ERR_REPLFILTER* = -150377298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:633:9
else:
  let YDB_ERR_REPLFILTER* = -150377298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:633:9
when -150377306 is static:
  const
    YDB_ERR_GBLMODFAIL* = -150377306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:634:9
else:
  let YDB_ERR_GBLMODFAIL* = -150377306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:634:9
when -150377314 is static:
  const
    YDB_ERR_TTLENGTHTOOBIG* = -150377314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:635:9
else:
  let YDB_ERR_TTLENGTHTOOBIG* = -150377314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:635:9
when -150377322 is static:
  const
    YDB_ERR_TPTIMEOUT* = -150377322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:636:9
else:
  let YDB_ERR_TPTIMEOUT* = -150377322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:636:9
when -150377330 is static:
  const
    YDB_ERR_NORTN* = -150377330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:637:9
else:
  let YDB_ERR_NORTN* = -150377330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:637:9
when -150377338 is static:
  const
    YDB_ERR_JNLFILNOTCHG* = -150377338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:638:9
else:
  let YDB_ERR_JNLFILNOTCHG* = -150377338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:638:9
when -150377346 is static:
  const
    YDB_ERR_EVENTLOGERR* = -150377346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:639:9
else:
  let YDB_ERR_EVENTLOGERR* = -150377346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:639:9
when -418812810 is static:
  const
    YDB_ERR_UPDATEFILEOPEN* = -418812810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:640:9
else:
  let YDB_ERR_UPDATEFILEOPEN* = -418812810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:640:9
when -150377362 is static:
  const
    YDB_ERR_JNLBADRECFMT* = -150377362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:641:9
else:
  let YDB_ERR_JNLBADRECFMT* = -150377362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:641:9
when -150377370 is static:
  const
    YDB_ERR_NULLCOLLDIFF* = -150377370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:642:9
else:
  let YDB_ERR_NULLCOLLDIFF* = -150377370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:642:9
when -150377376 is static:
  const
    YDB_ERR_MUKILLIP* = -150377376 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:643:9
else:
  let YDB_ERR_MUKILLIP* = -150377376 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:643:9
when -418812842 is static:
  const
    YDB_ERR_JNLRDONLY* = -418812842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:644:9
else:
  let YDB_ERR_JNLRDONLY* = -418812842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:644:9
when -150377394 is static:
  const
    YDB_ERR_ANCOMPTINC* = -150377394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:645:9
else:
  let YDB_ERR_ANCOMPTINC* = -150377394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:645:9
when -150377402 is static:
  const
    YDB_ERR_ABNCOMPTINC* = -150377402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:646:9
else:
  let YDB_ERR_ABNCOMPTINC* = -150377402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:646:9
when -150377410 is static:
  const
    YDB_ERR_RECLOAD* = -150377410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:647:9
else:
  let YDB_ERR_RECLOAD* = -150377410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:647:9
when -150377418 is static:
  const
    YDB_ERR_SOCKNOTFND* = -150377418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:648:9
else:
  let YDB_ERR_SOCKNOTFND* = -150377418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:648:9
when -150377426 is static:
  const
    YDB_ERR_CURRSOCKOFR* = -150377426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:649:9
else:
  let YDB_ERR_CURRSOCKOFR* = -150377426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:649:9
when -150377434 is static:
  const
    YDB_ERR_SOCKETEXIST* = -150377434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:650:9
else:
  let YDB_ERR_SOCKETEXIST* = -150377434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:650:9
when -150377442 is static:
  const
    YDB_ERR_LISTENPASSBND* = -150377442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:651:9
else:
  let YDB_ERR_LISTENPASSBND* = -150377442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:651:9
when -150377451 is static:
  const
    YDB_ERR_DBCLNUPINFO* = -150377451 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:652:9
else:
  let YDB_ERR_DBCLNUPINFO* = -150377451 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:652:9
when -150377458 is static:
  const
    YDB_ERR_MUNODWNGRD* = -150377458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:653:9
else:
  let YDB_ERR_MUNODWNGRD* = -150377458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:653:9
when -150377466 is static:
  const
    YDB_ERR_REPLTRANS2BIG* = -150377466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:654:9
else:
  let YDB_ERR_REPLTRANS2BIG* = -150377466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:654:9
when -150377474 is static:
  const
    YDB_ERR_RDFLTOOLONG* = -150377474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:655:9
else:
  let YDB_ERR_RDFLTOOLONG* = -150377474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:655:9
when -150377482 is static:
  const
    YDB_ERR_MUNOFINISH* = -150377482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:656:9
else:
  let YDB_ERR_MUNOFINISH* = -150377482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:656:9
when -150377491 is static:
  const
    YDB_ERR_DBFILEXT* = -150377491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:657:9
else:
  let YDB_ERR_DBFILEXT* = -150377491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:657:9
when -150377498 is static:
  const
    YDB_ERR_JNLFSYNCERR* = -150377498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:658:9
else:
  let YDB_ERR_JNLFSYNCERR* = -150377498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:658:9
when -150377504 is static:
  const
    YDB_ERR_ICUNOTENABLED* = -150377504 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:659:9
else:
  let YDB_ERR_ICUNOTENABLED* = -150377504 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:659:9
when -150377514 is static:
  const
    YDB_ERR_ZCPREALLVALINV* = -150377514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:660:9
else:
  let YDB_ERR_ZCPREALLVALINV* = -150377514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:660:9
when -150377523 is static:
  const
    YDB_ERR_NEWJNLFILECREAT* = -150377523 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:661:9
else:
  let YDB_ERR_NEWJNLFILECREAT* = -150377523 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:661:9
when -150377531 is static:
  const
    YDB_ERR_DSKSPACEFLOW* = -150377531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:662:9
else:
  let YDB_ERR_DSKSPACEFLOW* = -150377531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:662:9
when -150377538 is static:
  const
    YDB_ERR_GVINCRFAIL* = -150377538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:663:9
else:
  let YDB_ERR_GVINCRFAIL* = -150377538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:663:9
when -150377546 is static:
  const
    YDB_ERR_ISOLATIONSTSCHN* = -150377546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:664:9
else:
  let YDB_ERR_ISOLATIONSTSCHN* = -150377546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:664:9
when -150377554 is static:
  const
    YDB_ERR_UNUSEDMSG833* = -150377554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:665:9
else:
  let YDB_ERR_UNUSEDMSG833* = -150377554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:665:9
when -150377562 is static:
  const
    YDB_ERR_TRACEON* = -150377562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:666:9
else:
  let YDB_ERR_TRACEON* = -150377562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:666:9
when -150377570 is static:
  const
    YDB_ERR_TOOMANYCLIENTS* = -150377570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:667:9
else:
  let YDB_ERR_TOOMANYCLIENTS* = -150377570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:667:9
when -150377579 is static:
  const
    YDB_ERR_NOEXCLUDE* = -150377579 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:668:9
else:
  let YDB_ERR_NOEXCLUDE* = -150377579 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:668:9
when -150377586 is static:
  const
    YDB_ERR_UNUSEDMSG837* = -150377586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:669:9
else:
  let YDB_ERR_UNUSEDMSG837* = -150377586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:669:9
when -150377592 is static:
  const
    YDB_ERR_EXCLUDEREORG* = -150377592 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:670:9
else:
  let YDB_ERR_EXCLUDEREORG* = -150377592 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:670:9
when -150377600 is static:
  const
    YDB_ERR_REORGINC* = -150377600 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:671:9
else:
  let YDB_ERR_REORGINC* = -150377600 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:671:9
when -150377610 is static:
  const
    YDB_ERR_ASC2EBCDICCONV* = -150377610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:672:9
else:
  let YDB_ERR_ASC2EBCDICCONV* = -150377610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:672:9
when -150377618 is static:
  const
    YDB_ERR_GTMSECSHRSTART* = -150377618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:673:9
else:
  let YDB_ERR_GTMSECSHRSTART* = -150377618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:673:9
when -150377624 is static:
  const
    YDB_ERR_DBVERPERFWARN1* = -150377624 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:674:9
else:
  let YDB_ERR_DBVERPERFWARN1* = -150377624 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:674:9
when -150377634 is static:
  const
    YDB_ERR_FILEIDGBLSEC* = -150377634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:675:9
else:
  let YDB_ERR_FILEIDGBLSEC* = -150377634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:675:9
when -150377642 is static:
  const
    YDB_ERR_GBLSECNOTGDS* = -150377642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:676:9
else:
  let YDB_ERR_GBLSECNOTGDS* = -150377642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:676:9
when -150377650 is static:
  const
    YDB_ERR_BADGBLSECVER* = -150377650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:677:9
else:
  let YDB_ERR_BADGBLSECVER* = -150377650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:677:9
when -150377658 is static:
  const
    YDB_ERR_RECSIZENOTEVEN* = -150377658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:678:9
else:
  let YDB_ERR_RECSIZENOTEVEN* = -150377658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:678:9
when -150377666 is static:
  const
    YDB_ERR_BUFFLUFAILED* = -150377666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:679:9
else:
  let YDB_ERR_BUFFLUFAILED* = -150377666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:679:9
when -150377674 is static:
  const
    YDB_ERR_MUQUALINCOMP* = -150377674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:680:9
else:
  let YDB_ERR_MUQUALINCOMP* = -150377674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:680:9
when -150377682 is static:
  const
    YDB_ERR_DISTPATHMAX* = -150377682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:681:9
else:
  let YDB_ERR_DISTPATHMAX* = -150377682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:681:9
when -418813146 is static:
  const
    YDB_ERR_FILEOPENFAIL* = -418813146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:682:9
else:
  let YDB_ERR_FILEOPENFAIL* = -418813146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:682:9
when -150377698 is static:
  const
    YDB_ERR_UNUSEDMSG851* = -150377698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:683:9
else:
  let YDB_ERR_UNUSEDMSG851* = -150377698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:683:9
when -150377706 is static:
  const
    YDB_ERR_GTMSECSHRPERM* = -150377706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:684:9
else:
  let YDB_ERR_GTMSECSHRPERM* = -150377706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:684:9
when -150377714 is static:
  const
    YDB_ERR_YDBDISTUNDEF* = -150377714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:685:9
else:
  let YDB_ERR_YDBDISTUNDEF* = -150377714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:685:9
when -150377722 is static:
  const
    YDB_ERR_SYSCALL* = -150377722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:686:9
else:
  let YDB_ERR_SYSCALL* = -150377722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:686:9
when -150377730 is static:
  const
    YDB_ERR_MAXGTMPATH* = -150377730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:687:9
else:
  let YDB_ERR_MAXGTMPATH* = -150377730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:687:9
when -150377738 is static:
  const
    YDB_ERR_TROLLBK2DEEP* = -150377738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:688:9
else:
  let YDB_ERR_TROLLBK2DEEP* = -150377738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:688:9
when -150377746 is static:
  const
    YDB_ERR_INVROLLBKLVL* = -150377746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:689:9
else:
  let YDB_ERR_INVROLLBKLVL* = -150377746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:689:9
when -150377752 is static:
  const
    YDB_ERR_OLDBINEXTRACT* = -150377752 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:690:9
else:
  let YDB_ERR_OLDBINEXTRACT* = -150377752 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:690:9
when -150377762 is static:
  const
    YDB_ERR_ACOMPTBINC* = -150377762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:691:9
else:
  let YDB_ERR_ACOMPTBINC* = -150377762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:691:9
when -150377768 is static:
  const
    YDB_ERR_NOTREPLICATED* = -150377768 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:692:9
else:
  let YDB_ERR_NOTREPLICATED* = -150377768 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:692:9
when -150377778 is static:
  const
    YDB_ERR_DBPREMATEOF* = -150377778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:693:9
else:
  let YDB_ERR_DBPREMATEOF* = -150377778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:693:9
when -150377788 is static:
  const
    YDB_ERR_KILLBYSIG* = -150377788 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:694:9
else:
  let YDB_ERR_KILLBYSIG* = -150377788 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:694:9
when -150377796 is static:
  const
    YDB_ERR_KILLBYSIGUINFO* = -150377796 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:695:9
else:
  let YDB_ERR_KILLBYSIGUINFO* = -150377796 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:695:9
when -150377804 is static:
  const
    YDB_ERR_KILLBYSIGSINFO1* = -150377804 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:696:9
else:
  let YDB_ERR_KILLBYSIGSINFO1* = -150377804 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:696:9
when -150377812 is static:
  const
    YDB_ERR_KILLBYSIGSINFO2* = -150377812 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:697:9
else:
  let YDB_ERR_KILLBYSIGSINFO2* = -150377812 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:697:9
when -150377820 is static:
  const
    YDB_ERR_SIGILLOPC* = -150377820 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:698:9
else:
  let YDB_ERR_SIGILLOPC* = -150377820 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:698:9
when -150377828 is static:
  const
    YDB_ERR_SIGILLOPN* = -150377828 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:699:9
else:
  let YDB_ERR_SIGILLOPN* = -150377828 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:699:9
when -150377836 is static:
  const
    YDB_ERR_SIGILLADR* = -150377836 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:700:9
else:
  let YDB_ERR_SIGILLADR* = -150377836 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:700:9
when -150377844 is static:
  const
    YDB_ERR_SIGILLTRP* = -150377844 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:701:9
else:
  let YDB_ERR_SIGILLTRP* = -150377844 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:701:9
when -150377852 is static:
  const
    YDB_ERR_SIGPRVOPC* = -150377852 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:702:9
else:
  let YDB_ERR_SIGPRVOPC* = -150377852 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:702:9
when -150377860 is static:
  const
    YDB_ERR_SIGPRVREG* = -150377860 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:703:9
else:
  let YDB_ERR_SIGPRVREG* = -150377860 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:703:9
when -150377868 is static:
  const
    YDB_ERR_SIGCOPROC* = -150377868 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:704:9
else:
  let YDB_ERR_SIGCOPROC* = -150377868 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:704:9
when -150377876 is static:
  const
    YDB_ERR_SIGBADSTK* = -150377876 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:705:9
else:
  let YDB_ERR_SIGBADSTK* = -150377876 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:705:9
when -150377884 is static:
  const
    YDB_ERR_SIGADRALN* = -150377884 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:706:9
else:
  let YDB_ERR_SIGADRALN* = -150377884 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:706:9
when -150377892 is static:
  const
    YDB_ERR_SIGADRERR* = -150377892 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:707:9
else:
  let YDB_ERR_SIGADRERR* = -150377892 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:707:9
when -150377900 is static:
  const
    YDB_ERR_SIGOBJERR* = -150377900 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:708:9
else:
  let YDB_ERR_SIGOBJERR* = -150377900 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:708:9
when -150377908 is static:
  const
    YDB_ERR_SIGINTDIV* = -150377908 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:709:9
else:
  let YDB_ERR_SIGINTDIV* = -150377908 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:709:9
when -150377916 is static:
  const
    YDB_ERR_SIGINTOVF* = -150377916 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:710:9
else:
  let YDB_ERR_SIGINTOVF* = -150377916 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:710:9
when -150377924 is static:
  const
    YDB_ERR_SIGFLTDIV* = -150377924 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:711:9
else:
  let YDB_ERR_SIGFLTDIV* = -150377924 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:711:9
when -150377932 is static:
  const
    YDB_ERR_SIGFLTOVF* = -150377932 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:712:9
else:
  let YDB_ERR_SIGFLTOVF* = -150377932 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:712:9
when -150377940 is static:
  const
    YDB_ERR_SIGFLTUND* = -150377940 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:713:9
else:
  let YDB_ERR_SIGFLTUND* = -150377940 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:713:9
when -150377948 is static:
  const
    YDB_ERR_SIGFLTRES* = -150377948 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:714:9
else:
  let YDB_ERR_SIGFLTRES* = -150377948 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:714:9
when -150377956 is static:
  const
    YDB_ERR_SIGFLTINV* = -150377956 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:715:9
else:
  let YDB_ERR_SIGFLTINV* = -150377956 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:715:9
when -150377964 is static:
  const
    YDB_ERR_SIGMAPERR* = -150377964 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:716:9
else:
  let YDB_ERR_SIGMAPERR* = -150377964 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:716:9
when -418813428 is static:
  const
    YDB_ERR_SIGACCERR* = -418813428 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:717:9
else:
  let YDB_ERR_SIGACCERR* = -418813428 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:717:9
when -150377978 is static:
  const
    YDB_ERR_TRNLOGFAIL* = -150377978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:718:9
else:
  let YDB_ERR_TRNLOGFAIL* = -150377978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:718:9
when -150377986 is static:
  const
    YDB_ERR_INVDBGLVL* = -150377986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:719:9
else:
  let YDB_ERR_INVDBGLVL* = -150377986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:719:9
when -150377995 is static:
  const
    YDB_ERR_DBMAXNRSUBS* = -150377995 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:720:9
else:
  let YDB_ERR_DBMAXNRSUBS* = -150377995 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:720:9
when -150378002 is static:
  const
    YDB_ERR_GTMSECSHRSCKSEL* = -150378002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:721:9
else:
  let YDB_ERR_GTMSECSHRSCKSEL* = -150378002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:721:9
when -150378011 is static:
  const
    YDB_ERR_GTMSECSHRTMOUT* = -150378011 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:722:9
else:
  let YDB_ERR_GTMSECSHRTMOUT* = -150378011 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:722:9
when -150378018 is static:
  const
    YDB_ERR_GTMSECSHRRECVF* = -150378018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:723:9
else:
  let YDB_ERR_GTMSECSHRRECVF* = -150378018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:723:9
when -150378026 is static:
  const
    YDB_ERR_GTMSECSHRSENDF* = -150378026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:724:9
else:
  let YDB_ERR_GTMSECSHRSENDF* = -150378026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:724:9
when -150378034 is static:
  const
    YDB_ERR_SIZENOTVALID8* = -150378034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:725:9
else:
  let YDB_ERR_SIZENOTVALID8* = -150378034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:725:9
when -150378044 is static:
  const
    YDB_ERR_GTMSECSHROPCMP* = -150378044 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:726:9
else:
  let YDB_ERR_GTMSECSHROPCMP* = -150378044 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:726:9
when -150378048 is static:
  const
    YDB_ERR_GTMSECSHRSUIDF* = -150378048 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:727:9
else:
  let YDB_ERR_GTMSECSHRSUIDF* = -150378048 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:727:9
when -150378056 is static:
  const
    YDB_ERR_GTMSECSHRSGIDF* = -150378056 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:728:9
else:
  let YDB_ERR_GTMSECSHRSGIDF* = -150378056 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:728:9
when -150378064 is static:
  const
    YDB_ERR_GTMSECSHRSSIDF* = -150378064 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:729:9
else:
  let YDB_ERR_GTMSECSHRSSIDF* = -150378064 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:729:9
when -150378076 is static:
  const
    YDB_ERR_GTMSECSHRFORKF* = -150378076 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:730:9
else:
  let YDB_ERR_GTMSECSHRFORKF* = -150378076 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:730:9
when -150378082 is static:
  const
    YDB_ERR_DBFSYNCERR* = -150378082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:731:9
else:
  let YDB_ERR_DBFSYNCERR* = -150378082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:731:9
when -150378090 is static:
  const
    YDB_ERR_UNUSEDMSG900* = -150378090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:732:9
else:
  let YDB_ERR_UNUSEDMSG900* = -150378090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:732:9
when -150378098 is static:
  const
    YDB_ERR_SCNDDBNOUPD* = -150378098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:733:9
else:
  let YDB_ERR_SCNDDBNOUPD* = -150378098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:733:9
when -150378107 is static:
  const
    YDB_ERR_MUINFOUINT4* = -150378107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:734:9
else:
  let YDB_ERR_MUINFOUINT4* = -150378107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:734:9
when -150378114 is static:
  const
    YDB_ERR_NLMISMATCHCALC* = -150378114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:735:9
else:
  let YDB_ERR_NLMISMATCHCALC* = -150378114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:735:9
when -150378122 is static:
  const
    YDB_ERR_RELINKCTLFULL* = -150378122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:736:9
else:
  let YDB_ERR_RELINKCTLFULL* = -150378122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:736:9
when -150378128 is static:
  const
    YDB_ERR_MUPIPSET2BIG* = -150378128 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:737:9
else:
  let YDB_ERR_MUPIPSET2BIG* = -150378128 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:737:9
when -150378138 is static:
  const
    YDB_ERR_DBBADNSUB* = -150378138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:738:9
else:
  let YDB_ERR_DBBADNSUB* = -150378138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:738:9
when -150378146 is static:
  const
    YDB_ERR_DBBADKYNM* = -150378146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:739:9
else:
  let YDB_ERR_DBBADKYNM* = -150378146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:739:9
when -150378154 is static:
  const
    YDB_ERR_DBBADPNTR* = -150378154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:740:9
else:
  let YDB_ERR_DBBADPNTR* = -150378154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:740:9
when -150378162 is static:
  const
    YDB_ERR_DBBNPNTR* = -150378162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:741:9
else:
  let YDB_ERR_DBBNPNTR* = -150378162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:741:9
when -150378170 is static:
  const
    YDB_ERR_DBINCLVL* = -150378170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:742:9
else:
  let YDB_ERR_DBINCLVL* = -150378170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:742:9
when -150378178 is static:
  const
    YDB_ERR_DBBFSTAT* = -150378178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:743:9
else:
  let YDB_ERR_DBBFSTAT* = -150378178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:743:9
when -150378186 is static:
  const
    YDB_ERR_DBBDBALLOC* = -150378186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:744:9
else:
  let YDB_ERR_DBBDBALLOC* = -150378186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:744:9
when -150378194 is static:
  const
    YDB_ERR_DBMRKFREE* = -150378194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:745:9
else:
  let YDB_ERR_DBMRKFREE* = -150378194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:745:9
when -150378200 is static:
  const
    YDB_ERR_DBMRKBUSY* = -150378200 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:746:9
else:
  let YDB_ERR_DBMRKBUSY* = -150378200 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:746:9
when -150378210 is static:
  const
    YDB_ERR_DBBSIZZRO* = -150378210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:747:9
else:
  let YDB_ERR_DBBSIZZRO* = -150378210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:747:9
when -150378218 is static:
  const
    YDB_ERR_DBSZGT64K* = -150378218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:748:9
else:
  let YDB_ERR_DBSZGT64K* = -150378218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:748:9
when -150378226 is static:
  const
    YDB_ERR_DBNOTMLTP* = -150378226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:749:9
else:
  let YDB_ERR_DBNOTMLTP* = -150378226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:749:9
when -150378235 is static:
  const
    YDB_ERR_DBTNTOOLG* = -150378235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:750:9
else:
  let YDB_ERR_DBTNTOOLG* = -150378235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:750:9
when -150378242 is static:
  const
    YDB_ERR_DBBPLMLT512* = -150378242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:751:9
else:
  let YDB_ERR_DBBPLMLT512* = -150378242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:751:9
when -150378250 is static:
  const
    YDB_ERR_DBBPLMGT2K* = -150378250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:752:9
else:
  let YDB_ERR_DBBPLMGT2K* = -150378250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:752:9
when -150378259 is static:
  const
    YDB_ERR_MUINFOUINT8* = -150378259 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:753:9
else:
  let YDB_ERR_MUINFOUINT8* = -150378259 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:753:9
when -150378266 is static:
  const
    YDB_ERR_DBBPLNOT512* = -150378266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:754:9
else:
  let YDB_ERR_DBBPLNOT512* = -150378266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:754:9
when -150378275 is static:
  const
    YDB_ERR_MUINFOSTR* = -150378275 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:755:9
else:
  let YDB_ERR_MUINFOSTR* = -150378275 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:755:9
when -150378283 is static:
  const
    YDB_ERR_DBUNDACCMT* = -150378283 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:756:9
else:
  let YDB_ERR_DBUNDACCMT* = -150378283 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:756:9
when -150378291 is static:
  const
    YDB_ERR_DBTNNEQ* = -150378291 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:757:9
else:
  let YDB_ERR_DBTNNEQ* = -150378291 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:757:9
when -150378297 is static:
  const
    YDB_ERR_MUPGRDSUCC* = -150378297 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:758:9
else:
  let YDB_ERR_MUPGRDSUCC* = -150378297 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:758:9
when -150378307 is static:
  const
    YDB_ERR_DBDSRDFMTCHNG* = -150378307 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:759:9
else:
  let YDB_ERR_DBDSRDFMTCHNG* = -150378307 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:759:9
when -150378312 is static:
  const
    YDB_ERR_DBFGTBC* = -150378312 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:760:9
else:
  let YDB_ERR_DBFGTBC* = -150378312 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:760:9
when -150378322 is static:
  const
    YDB_ERR_DBFSTBC* = -150378322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:761:9
else:
  let YDB_ERR_DBFSTBC* = -150378322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:761:9
when -150378330 is static:
  const
    YDB_ERR_DBFSTHEAD* = -150378330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:762:9
else:
  let YDB_ERR_DBFSTHEAD* = -150378330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:762:9
when -150378338 is static:
  const
    YDB_ERR_DBCREINCOMP* = -150378338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:763:9
else:
  let YDB_ERR_DBCREINCOMP* = -150378338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:763:9
when -150378346 is static:
  const
    YDB_ERR_DBFLCORRP* = -150378346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:764:9
else:
  let YDB_ERR_DBFLCORRP* = -150378346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:764:9
when -150378354 is static:
  const
    YDB_ERR_DBHEADINV* = -150378354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:765:9
else:
  let YDB_ERR_DBHEADINV* = -150378354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:765:9
when -150378362 is static:
  const
    YDB_ERR_DBINCRVER* = -150378362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:766:9
else:
  let YDB_ERR_DBINCRVER* = -150378362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:766:9
when -150378370 is static:
  const
    YDB_ERR_DBINVGBL* = -150378370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:767:9
else:
  let YDB_ERR_DBINVGBL* = -150378370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:767:9
when -150378378 is static:
  const
    YDB_ERR_DBKEYGTIND* = -150378378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:768:9
else:
  let YDB_ERR_DBKEYGTIND* = -150378378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:768:9
when -150378386 is static:
  const
    YDB_ERR_DBGTDBMAX* = -150378386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:769:9
else:
  let YDB_ERR_DBGTDBMAX* = -150378386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:769:9
when -150378394 is static:
  const
    YDB_ERR_DBKGTALLW* = -150378394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:770:9
else:
  let YDB_ERR_DBKGTALLW* = -150378394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:770:9
when -150378402 is static:
  const
    YDB_ERR_DBLTSIBL* = -150378402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:771:9
else:
  let YDB_ERR_DBLTSIBL* = -150378402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:771:9
when -150378410 is static:
  const
    YDB_ERR_DBLRCINVSZ* = -150378410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:772:9
else:
  let YDB_ERR_DBLRCINVSZ* = -150378410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:772:9
when -150378419 is static:
  const
    YDB_ERR_MUREUPDWNGRDEND* = -150378419 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:773:9
else:
  let YDB_ERR_MUREUPDWNGRDEND* = -150378419 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:773:9
when -150378424 is static:
  const
    YDB_ERR_DBLOCMBINC* = -150378424 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:774:9
else:
  let YDB_ERR_DBLOCMBINC* = -150378424 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:774:9
when -150378432 is static:
  const
    YDB_ERR_DBLVLINC* = -150378432 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:775:9
else:
  let YDB_ERR_DBLVLINC* = -150378432 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:775:9
when -150378440 is static:
  const
    YDB_ERR_DBMBSIZMX* = -150378440 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:776:9
else:
  let YDB_ERR_DBMBSIZMX* = -150378440 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:776:9
when -150378450 is static:
  const
    YDB_ERR_DBMBSIZMN* = -150378450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:777:9
else:
  let YDB_ERR_DBMBSIZMN* = -150378450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:777:9
when -150378459 is static:
  const
    YDB_ERR_DBMBTNSIZMX* = -150378459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:778:9
else:
  let YDB_ERR_DBMBTNSIZMX* = -150378459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:778:9
when -150378464 is static:
  const
    YDB_ERR_DBMBMINCFRE* = -150378464 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:779:9
else:
  let YDB_ERR_DBMBMINCFRE* = -150378464 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:779:9
when -150378472 is static:
  const
    YDB_ERR_DBMBPINCFL* = -150378472 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:780:9
else:
  let YDB_ERR_DBMBPINCFL* = -150378472 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:780:9
when -150378480 is static:
  const
    YDB_ERR_DBMBPFLDLBM* = -150378480 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:781:9
else:
  let YDB_ERR_DBMBPFLDLBM* = -150378480 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:781:9
when -150378488 is static:
  const
    YDB_ERR_DBMBPFLINT* = -150378488 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:782:9
else:
  let YDB_ERR_DBMBPFLINT* = -150378488 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:782:9
when -150378496 is static:
  const
    YDB_ERR_DBMBPFLDIS* = -150378496 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:783:9
else:
  let YDB_ERR_DBMBPFLDIS* = -150378496 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:783:9
when -150378504 is static:
  const
    YDB_ERR_DBMBPFRDLBM* = -150378504 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:784:9
else:
  let YDB_ERR_DBMBPFRDLBM* = -150378504 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:784:9
when -150378512 is static:
  const
    YDB_ERR_DBMBPFRINT* = -150378512 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:785:9
else:
  let YDB_ERR_DBMBPFRINT* = -150378512 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:785:9
when -150378522 is static:
  const
    YDB_ERR_DBMAXKEYEXC* = -150378522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:786:9
else:
  let YDB_ERR_DBMAXKEYEXC* = -150378522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:786:9
when -150378530 is static:
  const
    YDB_ERR_REPLAHEAD* = -150378530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:787:9
else:
  let YDB_ERR_REPLAHEAD* = -150378530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:787:9
when -150378536 is static:
  const
    YDB_ERR_MUPIPSET2SML* = -150378536 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:788:9
else:
  let YDB_ERR_MUPIPSET2SML* = -150378536 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:788:9
when -150378546 is static:
  const
    YDB_ERR_DBREADBM* = -150378546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:789:9
else:
  let YDB_ERR_DBREADBM* = -150378546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:789:9
when -150378554 is static:
  const
    YDB_ERR_DBCOMPTOOLRG* = -150378554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:790:9
else:
  let YDB_ERR_DBCOMPTOOLRG* = -150378554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:790:9
when -150378560 is static:
  const
    YDB_ERR_DBVERPERFWARN2* = -150378560 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:791:9
else:
  let YDB_ERR_DBVERPERFWARN2* = -150378560 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:791:9
when -150378570 is static:
  const
    YDB_ERR_DBRBNTOOLRG* = -150378570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:792:9
else:
  let YDB_ERR_DBRBNTOOLRG* = -150378570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:792:9
when -150378578 is static:
  const
    YDB_ERR_DBRBNLBMN* = -150378578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:793:9
else:
  let YDB_ERR_DBRBNLBMN* = -150378578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:793:9
when -150378586 is static:
  const
    YDB_ERR_DBRBNNEG* = -150378586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:794:9
else:
  let YDB_ERR_DBRBNNEG* = -150378586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:794:9
when -150378594 is static:
  const
    YDB_ERR_DBRLEVTOOHI* = -150378594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:795:9
else:
  let YDB_ERR_DBRLEVTOOHI* = -150378594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:795:9
when -150378602 is static:
  const
    YDB_ERR_DBRLEVLTONE* = -150378602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:796:9
else:
  let YDB_ERR_DBRLEVLTONE* = -150378602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:796:9
when -150378610 is static:
  const
    YDB_ERR_DBSVBNMIN* = -150378610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:797:9
else:
  let YDB_ERR_DBSVBNMIN* = -150378610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:797:9
when -150378618 is static:
  const
    YDB_ERR_DBTTLBLK0* = -150378618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:798:9
else:
  let YDB_ERR_DBTTLBLK0* = -150378618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:798:9
when -150378626 is static:
  const
    YDB_ERR_DBNOTDB* = -150378626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:799:9
else:
  let YDB_ERR_DBNOTDB* = -150378626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:799:9
when -150378634 is static:
  const
    YDB_ERR_DBTOTBLK* = -150378634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:800:9
else:
  let YDB_ERR_DBTOTBLK* = -150378634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:800:9
when -150378643 is static:
  const
    YDB_ERR_DBTN* = -150378643 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:801:9
else:
  let YDB_ERR_DBTN* = -150378643 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:801:9
when -418814106 is static:
  const
    YDB_ERR_DBNOREGION* = -418814106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:802:9
else:
  let YDB_ERR_DBNOREGION* = -418814106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:802:9
when -150378656 is static:
  const
    YDB_ERR_DBTNRESETINC* = -150378656 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:803:9
else:
  let YDB_ERR_DBTNRESETINC* = -150378656 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:803:9
when -150378666 is static:
  const
    YDB_ERR_DBTNLTCTN* = -150378666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:804:9
else:
  let YDB_ERR_DBTNLTCTN* = -150378666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:804:9
when -150378674 is static:
  const
    YDB_ERR_DBTNRESET* = -150378674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:805:9
else:
  let YDB_ERR_DBTNRESET* = -150378674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:805:9
when -150378683 is static:
  const
    YDB_ERR_MUTEXRSRCCLNUP* = -150378683 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:806:9
else:
  let YDB_ERR_MUTEXRSRCCLNUP* = -150378683 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:806:9
when -150378690 is static:
  const
    YDB_ERR_SEMWT2LONG* = -150378690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:807:9
else:
  let YDB_ERR_SEMWT2LONG* = -150378690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:807:9
when -418814154 is static:
  const
    YDB_ERR_REPLINSTOPEN* = -418814154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:808:9
else:
  let YDB_ERR_REPLINSTOPEN* = -418814154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:808:9
when -150378706 is static:
  const
    YDB_ERR_REPLINSTCLOSE* = -150378706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:809:9
else:
  let YDB_ERR_REPLINSTCLOSE* = -150378706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:809:9
when -150378714 is static:
  const
    YDB_ERR_JOBSETUP* = -150378714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:810:9
else:
  let YDB_ERR_JOBSETUP* = -150378714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:810:9
when -150378723 is static:
  const
    YDB_ERR_DBCRERR8* = -150378723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:811:9
else:
  let YDB_ERR_DBCRERR8* = -150378723 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:811:9
when -150378728 is static:
  const
    YDB_ERR_NUMPROCESSORS* = -150378728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:812:9
else:
  let YDB_ERR_NUMPROCESSORS* = -150378728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:812:9
when -150378739 is static:
  const
    YDB_ERR_DBADDRANGE8* = -150378739 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:813:9
else:
  let YDB_ERR_DBADDRANGE8* = -150378739 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:813:9
when -150378747 is static:
  const
    YDB_ERR_RNDWNSEMFAIL* = -150378747 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:814:9
else:
  let YDB_ERR_RNDWNSEMFAIL* = -150378747 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:814:9
when -150378755 is static:
  const
    YDB_ERR_GTMSECSHRSHUTDN* = -150378755 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:815:9
else:
  let YDB_ERR_GTMSECSHRSHUTDN* = -150378755 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:815:9
when -150378762 is static:
  const
    YDB_ERR_NOSPACECRE* = -150378762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:816:9
else:
  let YDB_ERR_NOSPACECRE* = -150378762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:816:9
when -150378768 is static:
  const
    YDB_ERR_LOWSPACECRE* = -150378768 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:817:9
else:
  let YDB_ERR_LOWSPACECRE* = -150378768 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:817:9
when -150378779 is static:
  const
    YDB_ERR_WAITDSKSPACE* = -150378779 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:818:9
else:
  let YDB_ERR_WAITDSKSPACE* = -150378779 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:818:9
when -150378788 is static:
  const
    YDB_ERR_OUTOFSPACE* = -150378788 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:819:9
else:
  let YDB_ERR_OUTOFSPACE* = -150378788 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:819:9
when -150378795 is static:
  const
    YDB_ERR_JNLPVTINFO* = -150378795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:820:9
else:
  let YDB_ERR_JNLPVTINFO* = -150378795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:820:9
when -150378802 is static:
  const
    YDB_ERR_NOSPACEEXT* = -150378802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:821:9
else:
  let YDB_ERR_NOSPACEEXT* = -150378802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:821:9
when -150378808 is static:
  const
    YDB_ERR_WCBLOCKED* = -150378808 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:822:9
else:
  let YDB_ERR_WCBLOCKED* = -150378808 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:822:9
when -150378818 is static:
  const
    YDB_ERR_REPLJNLCLOSED* = -150378818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:823:9
else:
  let YDB_ERR_REPLJNLCLOSED* = -150378818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:823:9
when -150378824 is static:
  const
    YDB_ERR_RENAMEFAIL* = -150378824 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:824:9
else:
  let YDB_ERR_RENAMEFAIL* = -150378824 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:824:9
when -150378835 is static:
  const
    YDB_ERR_FILERENAME* = -150378835 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:825:9
else:
  let YDB_ERR_FILERENAME* = -150378835 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:825:9
when -150378843 is static:
  const
    YDB_ERR_JNLBUFINFO* = -150378843 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:826:9
else:
  let YDB_ERR_JNLBUFINFO* = -150378843 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:826:9
when -150378850 is static:
  const
    YDB_ERR_SDSEEKERR* = -150378850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:827:9
else:
  let YDB_ERR_SDSEEKERR* = -150378850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:827:9
when -150378858 is static:
  const
    YDB_ERR_LOCALSOCKREQ* = -150378858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:828:9
else:
  let YDB_ERR_LOCALSOCKREQ* = -150378858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:828:9
when -150378867 is static:
  const
    YDB_ERR_TPNOTACID* = -150378867 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:829:9
else:
  let YDB_ERR_TPNOTACID* = -150378867 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:829:9
when -150378874 is static:
  const
    YDB_ERR_JNLSETDATA2LONG* = -150378874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:830:9
else:
  let YDB_ERR_JNLSETDATA2LONG* = -150378874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:830:9
when -150378882 is static:
  const
    YDB_ERR_JNLNEWREC* = -150378882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:831:9
else:
  let YDB_ERR_JNLNEWREC* = -150378882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:831:9
when -150378890 is static:
  const
    YDB_ERR_REPLFTOKSEM* = -150378890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:832:9
else:
  let YDB_ERR_REPLFTOKSEM* = -150378890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:832:9
when -150378898 is static:
  const
    YDB_ERR_SOCKNOTPASSED* = -150378898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:833:9
else:
  let YDB_ERR_SOCKNOTPASSED* = -150378898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:833:9
when -150378906 is static:
  const
    YDB_ERR_UNUSEDMSG1002* = -150378906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:834:9
else:
  let YDB_ERR_UNUSEDMSG1002* = -150378906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:834:9
when -150378914 is static:
  const
    YDB_ERR_UNUSEDMSG1003* = -150378914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:835:9
else:
  let YDB_ERR_UNUSEDMSG1003* = -150378914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:835:9
when -150378922 is static:
  const
    YDB_ERR_CONNSOCKREQ* = -150378922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:836:9
else:
  let YDB_ERR_CONNSOCKREQ* = -150378922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:836:9
when -150378930 is static:
  const
    YDB_ERR_REPLEXITERR* = -150378930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:837:9
else:
  let YDB_ERR_REPLEXITERR* = -150378930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:837:9
when -150378939 is static:
  const
    YDB_ERR_MUDESTROYSUC* = -150378939 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:838:9
else:
  let YDB_ERR_MUDESTROYSUC* = -150378939 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:838:9
when -150378946 is static:
  const
    YDB_ERR_DBRNDWN* = -150378946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:839:9
else:
  let YDB_ERR_DBRNDWN* = -150378946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:839:9
when -150378955 is static:
  const
    YDB_ERR_MUDESTROYFAIL* = -150378955 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:840:9
else:
  let YDB_ERR_MUDESTROYFAIL* = -150378955 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:840:9
when -150378964 is static:
  const
    YDB_ERR_NOTALLDBOPN* = -150378964 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:841:9
else:
  let YDB_ERR_NOTALLDBOPN* = -150378964 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:841:9
when -150378970 is static:
  const
    YDB_ERR_MUSELFBKUP* = -150378970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:842:9
else:
  let YDB_ERR_MUSELFBKUP* = -150378970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:842:9
when -150378976 is static:
  const
    YDB_ERR_DBDANGER* = -150378976 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:843:9
else:
  let YDB_ERR_DBDANGER* = -150378976 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:843:9
when -150378986 is static:
  const
    YDB_ERR_UNUSEDMSG1012* = -150378986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:844:9
else:
  let YDB_ERR_UNUSEDMSG1012* = -150378986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:844:9
when -150378994 is static:
  const
    YDB_ERR_TCGETATTR* = -150378994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:845:9
else:
  let YDB_ERR_TCGETATTR* = -150378994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:845:9
when -150379002 is static:
  const
    YDB_ERR_TCSETATTR* = -150379002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:846:9
else:
  let YDB_ERR_TCSETATTR* = -150379002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:846:9
when -150379010 is static:
  const
    YDB_ERR_IOWRITERR* = -150379010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:847:9
else:
  let YDB_ERR_IOWRITERR* = -150379010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:847:9
when -418814474 is static:
  const
    YDB_ERR_REPLINSTWRITE* = -418814474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:848:9
else:
  let YDB_ERR_REPLINSTWRITE* = -418814474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:848:9
when -150379024 is static:
  const
    YDB_ERR_DBBADFREEBLKCTR* = -150379024 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:849:9
else:
  let YDB_ERR_DBBADFREEBLKCTR* = -150379024 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:849:9
when -150379035 is static:
  const
    YDB_ERR_REQ2RESUME* = -150379035 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:850:9
else:
  let YDB_ERR_REQ2RESUME* = -150379035 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:850:9
when -150379040 is static:
  const
    YDB_ERR_TIMERHANDLER* = -150379040 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:851:9
else:
  let YDB_ERR_TIMERHANDLER* = -150379040 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:851:9
when -150379050 is static:
  const
    YDB_ERR_FREEMEMORY* = -150379050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:852:9
else:
  let YDB_ERR_FREEMEMORY* = -150379050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:852:9
when -150379059 is static:
  const
    YDB_ERR_MUREPLSECDEL* = -150379059 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:853:9
else:
  let YDB_ERR_MUREPLSECDEL* = -150379059 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:853:9
when -150379067 is static:
  const
    YDB_ERR_MUREPLSECNOTDEL* = -150379067 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:854:9
else:
  let YDB_ERR_MUREPLSECNOTDEL* = -150379067 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:854:9
when -150379075 is static:
  const
    YDB_ERR_MUJPOOLRNDWNSUC* = -150379075 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:855:9
else:
  let YDB_ERR_MUJPOOLRNDWNSUC* = -150379075 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:855:9
when -150379083 is static:
  const
    YDB_ERR_MURPOOLRNDWNSUC* = -150379083 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:856:9
else:
  let YDB_ERR_MURPOOLRNDWNSUC* = -150379083 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:856:9
when -150379090 is static:
  const
    YDB_ERR_MUJPOOLRNDWNFL* = -150379090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:857:9
else:
  let YDB_ERR_MUJPOOLRNDWNFL* = -150379090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:857:9
when -150379098 is static:
  const
    YDB_ERR_MURPOOLRNDWNFL* = -150379098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:858:9
else:
  let YDB_ERR_MURPOOLRNDWNFL* = -150379098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:858:9
when -150379107 is static:
  const
    YDB_ERR_MUREPLPOOL* = -150379107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:859:9
else:
  let YDB_ERR_MUREPLPOOL* = -150379107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:859:9
when -150379114 is static:
  const
    YDB_ERR_REPLACCSEM* = -150379114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:860:9
else:
  let YDB_ERR_REPLACCSEM* = -150379114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:860:9
when -150379120 is static:
  const
    YDB_ERR_JNLFLUSHNOPROG* = -150379120 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:861:9
else:
  let YDB_ERR_JNLFLUSHNOPROG* = -150379120 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:861:9
when -150379130 is static:
  const
    YDB_ERR_REPLINSTCREATE* = -150379130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:862:9
else:
  let YDB_ERR_REPLINSTCREATE* = -150379130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:862:9
when -150379139 is static:
  const
    YDB_ERR_SUSPENDING* = -150379139 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:863:9
else:
  let YDB_ERR_SUSPENDING* = -150379139 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:863:9
when -150379146 is static:
  const
    YDB_ERR_SOCKBFNOTEMPTY* = -150379146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:864:9
else:
  let YDB_ERR_SOCKBFNOTEMPTY* = -150379146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:864:9
when -150379154 is static:
  const
    YDB_ERR_ILLESOCKBFSIZE* = -150379154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:865:9
else:
  let YDB_ERR_ILLESOCKBFSIZE* = -150379154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:865:9
when -150379162 is static:
  const
    YDB_ERR_NOSOCKETINDEV* = -150379162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:866:9
else:
  let YDB_ERR_NOSOCKETINDEV* = -150379162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:866:9
when -150379170 is static:
  const
    YDB_ERR_SETSOCKOPTERR* = -150379170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:867:9
else:
  let YDB_ERR_SETSOCKOPTERR* = -150379170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:867:9
when -150379178 is static:
  const
    YDB_ERR_GETSOCKOPTERR* = -150379178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:868:9
else:
  let YDB_ERR_GETSOCKOPTERR* = -150379178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:868:9
when -150379187 is static:
  const
    YDB_ERR_NOSUCHPROC* = -150379187 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:869:9
else:
  let YDB_ERR_NOSUCHPROC* = -150379187 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:869:9
when -150379194 is static:
  const
    YDB_ERR_DSENOFINISH* = -150379194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:870:9
else:
  let YDB_ERR_DSENOFINISH* = -150379194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:870:9
when -150379202 is static:
  const
    YDB_ERR_LKENOFINISH* = -150379202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:871:9
else:
  let YDB_ERR_LKENOFINISH* = -150379202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:871:9
when -150379212 is static:
  const
    YDB_ERR_NOCHLEFT* = -150379212 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:872:9
else:
  let YDB_ERR_NOCHLEFT* = -150379212 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:872:9
when -150379218 is static:
  const
    YDB_ERR_MULOGNAMEDEF* = -150379218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:873:9
else:
  let YDB_ERR_MULOGNAMEDEF* = -150379218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:873:9
when -150379226 is static:
  const
    YDB_ERR_BUFOWNERSTUCK* = -150379226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:874:9
else:
  let YDB_ERR_BUFOWNERSTUCK* = -150379226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:874:9
when -150379234 is static:
  const
    YDB_ERR_ACTIVATEFAIL* = -150379234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:875:9
else:
  let YDB_ERR_ACTIVATEFAIL* = -150379234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:875:9
when -150379240 is static:
  const
    YDB_ERR_DBRNDWNWRN* = -150379240 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:876:9
else:
  let YDB_ERR_DBRNDWNWRN* = -150379240 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:876:9
when -150379250 is static:
  const
    YDB_ERR_DLLNOOPEN* = -150379250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:877:9
else:
  let YDB_ERR_DLLNOOPEN* = -150379250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:877:9
when -150379258 is static:
  const
    YDB_ERR_DLLNORTN* = -150379258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:878:9
else:
  let YDB_ERR_DLLNORTN* = -150379258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:878:9
when -150379266 is static:
  const
    YDB_ERR_DLLNOCLOSE* = -150379266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:879:9
else:
  let YDB_ERR_DLLNOCLOSE* = -150379266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:879:9
when -150379274 is static:
  const
    YDB_ERR_FILTERNOTALIVE* = -150379274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:880:9
else:
  let YDB_ERR_FILTERNOTALIVE* = -150379274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:880:9
when -150379282 is static:
  const
    YDB_ERR_FILTERCOMM* = -150379282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:881:9
else:
  let YDB_ERR_FILTERCOMM* = -150379282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:881:9
when -150379290 is static:
  const
    YDB_ERR_FILTERBADCONV* = -150379290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:882:9
else:
  let YDB_ERR_FILTERBADCONV* = -150379290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:882:9
when -150379298 is static:
  const
    YDB_ERR_PRIMARYISROOT* = -150379298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:883:9
else:
  let YDB_ERR_PRIMARYISROOT* = -150379298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:883:9
when -150379306 is static:
  const
    YDB_ERR_GVQUERYGETFAIL* = -150379306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:884:9
else:
  let YDB_ERR_GVQUERYGETFAIL* = -150379306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:884:9
when -150379314 is static:
  const
    YDB_ERR_UNUSEDMSG1053* = -150379314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:885:9
else:
  let YDB_ERR_UNUSEDMSG1053* = -150379314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:885:9
when -150379322 is static:
  const
    YDB_ERR_MERGEDESC* = -150379322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:886:9
else:
  let YDB_ERR_MERGEDESC* = -150379322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:886:9
when -150379328 is static:
  const
    YDB_ERR_MERGEINCOMPL* = -150379328 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:887:9
else:
  let YDB_ERR_MERGEINCOMPL* = -150379328 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:887:9
when -150379338 is static:
  const
    YDB_ERR_DBNAMEMISMATCH* = -150379338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:888:9
else:
  let YDB_ERR_DBNAMEMISMATCH* = -150379338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:888:9
when -150379346 is static:
  const
    YDB_ERR_DBIDMISMATCH* = -150379346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:889:9
else:
  let YDB_ERR_DBIDMISMATCH* = -150379346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:889:9
when -150379354 is static:
  const
    YDB_ERR_DEVOPENFAIL* = -150379354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:890:9
else:
  let YDB_ERR_DEVOPENFAIL* = -150379354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:890:9
when -150379363 is static:
  const
    YDB_ERR_IPCNOTDEL* = -150379363 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:891:9
else:
  let YDB_ERR_IPCNOTDEL* = -150379363 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:891:9
when -150379370 is static:
  const
    YDB_ERR_XCVOIDRET* = -150379370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:892:9
else:
  let YDB_ERR_XCVOIDRET* = -150379370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:892:9
when -150379378 is static:
  const
    YDB_ERR_MURAIMGFAIL* = -150379378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:893:9
else:
  let YDB_ERR_MURAIMGFAIL* = -150379378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:893:9
when -150379386 is static:
  const
    YDB_ERR_REPLINSTUNDEF* = -150379386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:894:9
else:
  let YDB_ERR_REPLINSTUNDEF* = -150379386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:894:9
when -150379394 is static:
  const
    YDB_ERR_REPLINSTACC* = -150379394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:895:9
else:
  let YDB_ERR_REPLINSTACC* = -150379394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:895:9
when -150379402 is static:
  const
    YDB_ERR_NOJNLPOOL* = -150379402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:896:9
else:
  let YDB_ERR_NOJNLPOOL* = -150379402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:896:9
when -150379410 is static:
  const
    YDB_ERR_NORECVPOOL* = -150379410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:897:9
else:
  let YDB_ERR_NORECVPOOL* = -150379410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:897:9
when -150379418 is static:
  const
    YDB_ERR_FTOKERR* = -150379418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:898:9
else:
  let YDB_ERR_FTOKERR* = -150379418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:898:9
when -150379426 is static:
  const
    YDB_ERR_REPLREQRUNDOWN* = -150379426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:899:9
else:
  let YDB_ERR_REPLREQRUNDOWN* = -150379426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:899:9
when -150379435 is static:
  const
    YDB_ERR_BLKCNTEDITFAIL* = -150379435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:900:9
else:
  let YDB_ERR_BLKCNTEDITFAIL* = -150379435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:900:9
when -150379443 is static:
  const
    YDB_ERR_SEMREMOVED* = -150379443 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:901:9
else:
  let YDB_ERR_SEMREMOVED* = -150379443 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:901:9
when -150379450 is static:
  const
    YDB_ERR_REPLINSTFMT* = -150379450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:902:9
else:
  let YDB_ERR_REPLINSTFMT* = -150379450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:902:9
when -150379458 is static:
  const
    YDB_ERR_SEMKEYINUSE* = -150379458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:903:9
else:
  let YDB_ERR_SEMKEYINUSE* = -150379458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:903:9
when -150379466 is static:
  const
    YDB_ERR_XTRNTRANSERR* = -150379466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:904:9
else:
  let YDB_ERR_XTRNTRANSERR* = -150379466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:904:9
when -150379474 is static:
  const
    YDB_ERR_XTRNTRANSDLL* = -150379474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:905:9
else:
  let YDB_ERR_XTRNTRANSDLL* = -150379474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:905:9
when -150379482 is static:
  const
    YDB_ERR_XTRNRETVAL* = -150379482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:906:9
else:
  let YDB_ERR_XTRNRETVAL* = -150379482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:906:9
when -150379490 is static:
  const
    YDB_ERR_XTRNRETSTR* = -150379490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:907:9
else:
  let YDB_ERR_XTRNRETSTR* = -150379490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:907:9
when -150379498 is static:
  const
    YDB_ERR_INVECODEVAL* = -150379498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:908:9
else:
  let YDB_ERR_INVECODEVAL* = -150379498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:908:9
when -150379506 is static:
  const
    YDB_ERR_SETECODE* = -150379506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:909:9
else:
  let YDB_ERR_SETECODE* = -150379506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:909:9
when -150379514 is static:
  const
    YDB_ERR_INVSTACODE* = -150379514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:910:9
else:
  let YDB_ERR_INVSTACODE* = -150379514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:910:9
when -150379522 is static:
  const
    YDB_ERR_REPEATERROR* = -150379522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:911:9
else:
  let YDB_ERR_REPEATERROR* = -150379522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:911:9
when -150379530 is static:
  const
    YDB_ERR_NOCANONICNAME* = -150379530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:912:9
else:
  let YDB_ERR_NOCANONICNAME* = -150379530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:912:9
when -150379538 is static:
  const
    YDB_ERR_NOSUBSCRIPT* = -150379538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:913:9
else:
  let YDB_ERR_NOSUBSCRIPT* = -150379538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:913:9
when -150379546 is static:
  const
    YDB_ERR_SYSTEMVALUE* = -150379546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:914:9
else:
  let YDB_ERR_SYSTEMVALUE* = -150379546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:914:9
when -150379554 is static:
  const
    YDB_ERR_SIZENOTVALID4* = -150379554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:915:9
else:
  let YDB_ERR_SIZENOTVALID4* = -150379554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:915:9
when -150379562 is static:
  const
    YDB_ERR_STRNOTVALID* = -150379562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:916:9
else:
  let YDB_ERR_STRNOTVALID* = -150379562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:916:9
when -150379570 is static:
  const
    YDB_ERR_CREDNOTPASSED* = -150379570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:917:9
else:
  let YDB_ERR_CREDNOTPASSED* = -150379570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:917:9
when -150379578 is static:
  const
    YDB_ERR_ERRWETRAP* = -150379578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:918:9
else:
  let YDB_ERR_ERRWETRAP* = -150379578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:918:9
when -150379587 is static:
  const
    YDB_ERR_TRACINGON* = -150379587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:919:9
else:
  let YDB_ERR_TRACINGON* = -150379587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:919:9
when -150379594 is static:
  const
    YDB_ERR_CITABENV* = -150379594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:920:9
else:
  let YDB_ERR_CITABENV* = -150379594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:920:9
when -150379602 is static:
  const
    YDB_ERR_CITABOPN* = -150379602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:921:9
else:
  let YDB_ERR_CITABOPN* = -150379602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:921:9
when -150379610 is static:
  const
    YDB_ERR_CIENTNAME* = -150379610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:922:9
else:
  let YDB_ERR_CIENTNAME* = -150379610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:922:9
when -150379618 is static:
  const
    YDB_ERR_CIRTNTYP* = -150379618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:923:9
else:
  let YDB_ERR_CIRTNTYP* = -150379618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:923:9
when -150379626 is static:
  const
    YDB_ERR_CIRCALLNAME* = -150379626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:924:9
else:
  let YDB_ERR_CIRCALLNAME* = -150379626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:924:9
when -150379634 is static:
  const
    YDB_ERR_CIRPARMNAME* = -150379634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:925:9
else:
  let YDB_ERR_CIRPARMNAME* = -150379634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:925:9
when -150379642 is static:
  const
    YDB_ERR_CIDIRECTIVE* = -150379642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:926:9
else:
  let YDB_ERR_CIDIRECTIVE* = -150379642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:926:9
when -150379650 is static:
  const
    YDB_ERR_CIPARTYPE* = -150379650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:927:9
else:
  let YDB_ERR_CIPARTYPE* = -150379650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:927:9
when -150379658 is static:
  const
    YDB_ERR_CIUNTYPE* = -150379658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:928:9
else:
  let YDB_ERR_CIUNTYPE* = -150379658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:928:9
when -150379666 is static:
  const
    YDB_ERR_CINOENTRY* = -150379666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:929:9
else:
  let YDB_ERR_CINOENTRY* = -150379666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:929:9
when -150379674 is static:
  const
    YDB_ERR_JNLINVSWITCHLMT* = -150379674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:930:9
else:
  let YDB_ERR_JNLINVSWITCHLMT* = -150379674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:930:9
when -418815138 is static:
  const
    YDB_ERR_SETZDIR* = -418815138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:931:9
else:
  let YDB_ERR_SETZDIR* = -418815138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:931:9
when -150379690 is static:
  const
    YDB_ERR_JOBACTREF* = -150379690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:932:9
else:
  let YDB_ERR_JOBACTREF* = -150379690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:932:9
when -150379696 is static:
  const
    YDB_ERR_ECLOSTMID* = -150379696 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:933:9
else:
  let YDB_ERR_ECLOSTMID* = -150379696 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:933:9
when -150379706 is static:
  const
    YDB_ERR_ZFF2MANY* = -150379706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:934:9
else:
  let YDB_ERR_ZFF2MANY* = -150379706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:934:9
when -150379712 is static:
  const
    YDB_ERR_JNLFSYNCLSTCK* = -150379712 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:935:9
else:
  let YDB_ERR_JNLFSYNCLSTCK* = -150379712 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:935:9
when -150379722 is static:
  const
    YDB_ERR_DELIMWIDTH* = -150379722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:936:9
else:
  let YDB_ERR_DELIMWIDTH* = -150379722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:936:9
when -150379730 is static:
  const
    YDB_ERR_DBBMLCORRUPT* = -150379730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:937:9
else:
  let YDB_ERR_DBBMLCORRUPT* = -150379730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:937:9
when -150379738 is static:
  const
    YDB_ERR_DLCKAVOIDANCE* = -150379738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:938:9
else:
  let YDB_ERR_DLCKAVOIDANCE* = -150379738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:938:9
when -150379746 is static:
  const
    YDB_ERR_WRITERSTUCK* = -150379746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:939:9
else:
  let YDB_ERR_WRITERSTUCK* = -150379746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:939:9
when -150379754 is static:
  const
    YDB_ERR_PATNOTFOUND* = -150379754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:940:9
else:
  let YDB_ERR_PATNOTFOUND* = -150379754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:940:9
when -150379762 is static:
  const
    YDB_ERR_INVZDIRFORM* = -150379762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:941:9
else:
  let YDB_ERR_INVZDIRFORM* = -150379762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:941:9
when -150379768 is static:
  const
    YDB_ERR_ZDIROUTOFSYNC* = -150379768 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:942:9
else:
  let YDB_ERR_ZDIROUTOFSYNC* = -150379768 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:942:9
when -150379779 is static:
  const
    YDB_ERR_GBLNOEXIST* = -150379779 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:943:9
else:
  let YDB_ERR_GBLNOEXIST* = -150379779 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:943:9
when -150379786 is static:
  const
    YDB_ERR_MAXBTLEVEL* = -150379786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:944:9
else:
  let YDB_ERR_MAXBTLEVEL* = -150379786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:944:9
when -150379794 is static:
  const
    YDB_ERR_INVMNEMCSPC* = -150379794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:945:9
else:
  let YDB_ERR_INVMNEMCSPC* = -150379794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:945:9
when -150379803 is static:
  const
    YDB_ERR_JNLALIGNSZCHG* = -150379803 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:946:9
else:
  let YDB_ERR_JNLALIGNSZCHG* = -150379803 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:946:9
when -150379810 is static:
  const
    YDB_ERR_SEFCTNEEDSFULLB* = -150379810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:947:9
else:
  let YDB_ERR_SEFCTNEEDSFULLB* = -150379810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:947:9
when -150379818 is static:
  const
    YDB_ERR_GVFAILCORE* = -150379818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:948:9
else:
  let YDB_ERR_GVFAILCORE* = -150379818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:948:9
when -150379826 is static:
  const
    YDB_ERR_UNUSEDMSG1117* = -150379826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:949:9
else:
  let YDB_ERR_UNUSEDMSG1117* = -150379826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:949:9
when -150379835 is static:
  const
    YDB_ERR_DBFRZRESETSUC* = -150379835 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:950:9
else:
  let YDB_ERR_DBFRZRESETSUC* = -150379835 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:950:9
when -150379842 is static:
  const
    YDB_ERR_JNLFILEXTERR* = -150379842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:951:9
else:
  let YDB_ERR_JNLFILEXTERR* = -150379842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:951:9
when -150379851 is static:
  const
    YDB_ERR_JOBEXAMDONE* = -150379851 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:952:9
else:
  let YDB_ERR_JOBEXAMDONE* = -150379851 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:952:9
when -150379858 is static:
  const
    YDB_ERR_JOBEXAMFAIL* = -150379858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:953:9
else:
  let YDB_ERR_JOBEXAMFAIL* = -150379858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:953:9
when -150379866 is static:
  const
    YDB_ERR_JOBINTRRQST* = -150379866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:954:9
else:
  let YDB_ERR_JOBINTRRQST* = -150379866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:954:9
when -150379874 is static:
  const
    YDB_ERR_ERRWZINTR* = -150379874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:955:9
else:
  let YDB_ERR_ERRWZINTR* = -150379874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:955:9
when -150379882 is static:
  const
    YDB_ERR_CLIERR* = -150379882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:956:9
else:
  let YDB_ERR_CLIERR* = -150379882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:956:9
when -150379888 is static:
  const
    YDB_ERR_REPLNOBEFORE* = -150379888 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:957:9
else:
  let YDB_ERR_REPLNOBEFORE* = -150379888 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:957:9
when -150379896 is static:
  const
    YDB_ERR_REPLJNLCNFLCT* = -150379896 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:958:9
else:
  let YDB_ERR_REPLJNLCNFLCT* = -150379896 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:958:9
when -150379904 is static:
  const
    YDB_ERR_JNLDISABLE* = -150379904 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:959:9
else:
  let YDB_ERR_JNLDISABLE* = -150379904 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:959:9
when -150379914 is static:
  const
    YDB_ERR_FILEEXISTS* = -150379914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:960:9
else:
  let YDB_ERR_FILEEXISTS* = -150379914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:960:9
when -150379923 is static:
  const
    YDB_ERR_JNLSTATE* = -150379923 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:961:9
else:
  let YDB_ERR_JNLSTATE* = -150379923 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:961:9
when -150379931 is static:
  const
    YDB_ERR_REPLSTATE* = -150379931 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:962:9
else:
  let YDB_ERR_REPLSTATE* = -150379931 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:962:9
when -150379939 is static:
  const
    YDB_ERR_JNLCREATE* = -150379939 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:963:9
else:
  let YDB_ERR_JNLCREATE* = -150379939 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:963:9
when -150379946 is static:
  const
    YDB_ERR_JNLNOCREATE* = -150379946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:964:9
else:
  let YDB_ERR_JNLNOCREATE* = -150379946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:964:9
when -150379955 is static:
  const
    YDB_ERR_JNLFNF* = -150379955 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:965:9
else:
  let YDB_ERR_JNLFNF* = -150379955 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:965:9
when -150379963 is static:
  const
    YDB_ERR_PREVJNLLINKCUT* = -150379963 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:966:9
else:
  let YDB_ERR_PREVJNLLINKCUT* = -150379963 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:966:9
when -150379971 is static:
  const
    YDB_ERR_PREVJNLLINKSET* = -150379971 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:967:9
else:
  let YDB_ERR_PREVJNLLINKSET* = -150379971 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:967:9
when -150379978 is static:
  const
    YDB_ERR_FILENAMETOOLONG* = -150379978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:968:9
else:
  let YDB_ERR_FILENAMETOOLONG* = -150379978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:968:9
when -150379986 is static:
  const
    YDB_ERR_REQRECOV* = -150379986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:969:9
else:
  let YDB_ERR_REQRECOV* = -150379986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:969:9
when -150379994 is static:
  const
    YDB_ERR_JNLTRANS2BIG* = -150379994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:970:9
else:
  let YDB_ERR_JNLTRANS2BIG* = -150379994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:970:9
when -150380002 is static:
  const
    YDB_ERR_JNLSWITCHTOOSM* = -150380002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:971:9
else:
  let YDB_ERR_JNLSWITCHTOOSM* = -150380002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:971:9
when -150380011 is static:
  const
    YDB_ERR_JNLSWITCHSZCHG* = -150380011 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:972:9
else:
  let YDB_ERR_JNLSWITCHSZCHG* = -150380011 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:972:9
when -150380018 is static:
  const
    YDB_ERR_NOTRNDMACC* = -150380018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:973:9
else:
  let YDB_ERR_NOTRNDMACC* = -150380018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:973:9
when -150380026 is static:
  const
    YDB_ERR_TMPFILENOCRE* = -150380026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:974:9
else:
  let YDB_ERR_TMPFILENOCRE* = -150380026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:974:9
when -150380034 is static:
  const
    YDB_ERR_DEVICEOPTION* = -150380034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:975:9
else:
  let YDB_ERR_DEVICEOPTION* = -150380034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:975:9
when -150380043 is static:
  const
    YDB_ERR_JNLSENDOPER* = -150380043 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:976:9
else:
  let YDB_ERR_JNLSENDOPER* = -150380043 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:976:9
when -150380050 is static:
  const
    YDB_ERR_UNUSEDMSG1145* = -150380050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:977:9
else:
  let YDB_ERR_UNUSEDMSG1145* = -150380050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:977:9
when -150380058 is static:
  const
    YDB_ERR_UNUSEDMSG1146* = -150380058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:978:9
else:
  let YDB_ERR_UNUSEDMSG1146* = -150380058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:978:9
when -150380066 is static:
  const
    YDB_ERR_UNUSEDMSG1147* = -150380066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:979:9
else:
  let YDB_ERR_UNUSEDMSG1147* = -150380066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:979:9
when -150380074 is static:
  const
    YDB_ERR_UNUSEDMSG1148* = -150380074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:980:9
else:
  let YDB_ERR_UNUSEDMSG1148* = -150380074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:980:9
when -150380082 is static:
  const
    YDB_ERR_UNUSEDMSG1149* = -150380082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:981:9
else:
  let YDB_ERR_UNUSEDMSG1149* = -150380082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:981:9
when -150380090 is static:
  const
    YDB_ERR_UNUSEDMSG1150* = -150380090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:982:9
else:
  let YDB_ERR_UNUSEDMSG1150* = -150380090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:982:9
when -150380098 is static:
  const
    YDB_ERR_UNUSEDMSG1151* = -150380098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:983:9
else:
  let YDB_ERR_UNUSEDMSG1151* = -150380098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:983:9
when -150380106 is static:
  const
    YDB_ERR_UNUSEDMSG1152* = -150380106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:984:9
else:
  let YDB_ERR_UNUSEDMSG1152* = -150380106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:984:9
when -150380113 is static:
  const
    YDB_ERR_UNUSEDMSG1153* = -150380113 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:985:9
else:
  let YDB_ERR_UNUSEDMSG1153* = -150380113 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:985:9
when -150380121 is static:
  const
    YDB_ERR_UNUSEDMSG1154* = -150380121 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:986:9
else:
  let YDB_ERR_UNUSEDMSG1154* = -150380121 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:986:9
when -150380128 is static:
  const
    YDB_ERR_UNUSEDMSG1155* = -150380128 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:987:9
else:
  let YDB_ERR_UNUSEDMSG1155* = -150380128 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:987:9
when -150380138 is static:
  const
    YDB_ERR_UNUSEDMSG1156* = -150380138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:988:9
else:
  let YDB_ERR_UNUSEDMSG1156* = -150380138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:988:9
when -150380146 is static:
  const
    YDB_ERR_UNUSEDMSG1157* = -150380146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:989:9
else:
  let YDB_ERR_UNUSEDMSG1157* = -150380146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:989:9
when -150380154 is static:
  const
    YDB_ERR_UNUSEDMSG1158* = -150380154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:990:9
else:
  let YDB_ERR_UNUSEDMSG1158* = -150380154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:990:9
when -150380162 is static:
  const
    YDB_ERR_UNUSEDMSG1159* = -150380162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:991:9
else:
  let YDB_ERR_UNUSEDMSG1159* = -150380162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:991:9
when -150380170 is static:
  const
    YDB_ERR_UNUSEDMSG1160* = -150380170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:992:9
else:
  let YDB_ERR_UNUSEDMSG1160* = -150380170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:992:9
when -150380178 is static:
  const
    YDB_ERR_UNUSEDMSG1161* = -150380178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:993:9
else:
  let YDB_ERR_UNUSEDMSG1161* = -150380178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:993:9
when -150380186 is static:
  const
    YDB_ERR_MUTEXRELEASED* = -150380186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:994:9
else:
  let YDB_ERR_MUTEXRELEASED* = -150380186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:994:9
when -150380192 is static:
  const
    YDB_ERR_JNLCRESTATUS* = -150380192 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:995:9
else:
  let YDB_ERR_JNLCRESTATUS* = -150380192 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:995:9
when -150380203 is static:
  const
    YDB_ERR_ZBREAKFAIL* = -150380203 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:996:9
else:
  let YDB_ERR_ZBREAKFAIL* = -150380203 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:996:9
when -150380210 is static:
  const
    YDB_ERR_DLLVERSION* = -150380210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:997:9
else:
  let YDB_ERR_DLLVERSION* = -150380210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:997:9
when -150380218 is static:
  const
    YDB_ERR_INVZROENT* = -150380218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:998:9
else:
  let YDB_ERR_INVZROENT* = -150380218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:998:9
when -150380226 is static:
  const
    YDB_ERR_UNUSEDMSG1167* = -150380226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:999:9
else:
  let YDB_ERR_UNUSEDMSG1167* = -150380226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:999:9
when -150380234 is static:
  const
    YDB_ERR_GETSOCKNAMERR* = -150380234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1000:9
else:
  let YDB_ERR_GETSOCKNAMERR* = -150380234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1000:9
when -150380242 is static:
  const
    YDB_ERR_INVYDBEXIT* = -150380242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1001:9
else:
  let YDB_ERR_INVYDBEXIT* = -150380242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1001:9
when -150380250 is static:
  const
    YDB_ERR_CIMAXPARAM* = -150380250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1002:9
else:
  let YDB_ERR_CIMAXPARAM* = -150380250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1002:9
when -150380258 is static:
  const
    YDB_ERR_UNUSEDMSG1171* = -150380258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1003:9
else:
  let YDB_ERR_UNUSEDMSG1171* = -150380258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1003:9
when -150380266 is static:
  const
    YDB_ERR_CIMAXLEVELS* = -150380266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1004:9
else:
  let YDB_ERR_CIMAXLEVELS* = -150380266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1004:9
when -150380274 is static:
  const
    YDB_ERR_JOBINTRRETHROW* = -150380274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1005:9
else:
  let YDB_ERR_JOBINTRRETHROW* = -150380274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1005:9
when -150380282 is static:
  const
    YDB_ERR_STARFILE* = -150380282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1006:9
else:
  let YDB_ERR_STARFILE* = -150380282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1006:9
when -150380290 is static:
  const
    YDB_ERR_NOSTARFILE* = -150380290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1007:9
else:
  let YDB_ERR_NOSTARFILE* = -150380290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1007:9
when -150380299 is static:
  const
    YDB_ERR_MUJNLSTAT* = -150380299 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1008:9
else:
  let YDB_ERR_MUJNLSTAT* = -150380299 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1008:9
when -150380304 is static:
  const
    YDB_ERR_JNLTPNEST* = -150380304 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1009:9
else:
  let YDB_ERR_JNLTPNEST* = -150380304 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1009:9
when -150380314 is static:
  const
    YDB_ERR_REPLOFFJNLON* = -150380314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1010:9
else:
  let YDB_ERR_REPLOFFJNLON* = -150380314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1010:9
when -150380320 is static:
  const
    YDB_ERR_FILEDELFAIL* = -150380320 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1011:9
else:
  let YDB_ERR_FILEDELFAIL* = -150380320 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1011:9
when -150380330 is static:
  const
    YDB_ERR_INVQUALTIME* = -150380330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1012:9
else:
  let YDB_ERR_INVQUALTIME* = -150380330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1012:9
when -150380338 is static:
  const
    YDB_ERR_NOTPOSITIVE* = -150380338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1013:9
else:
  let YDB_ERR_NOTPOSITIVE* = -150380338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1013:9
when -150380346 is static:
  const
    YDB_ERR_INVREDIRQUAL* = -150380346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1014:9
else:
  let YDB_ERR_INVREDIRQUAL* = -150380346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1014:9
when -150380354 is static:
  const
    YDB_ERR_INVERRORLIM* = -150380354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1015:9
else:
  let YDB_ERR_INVERRORLIM* = -150380354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1015:9
when -150380362 is static:
  const
    YDB_ERR_INVIDQUAL* = -150380362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1016:9
else:
  let YDB_ERR_INVIDQUAL* = -150380362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1016:9
when -150380370 is static:
  const
    YDB_ERR_INVTRNSQUAL* = -150380370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1017:9
else:
  let YDB_ERR_INVTRNSQUAL* = -150380370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1017:9
when -150380378 is static:
  const
    YDB_ERR_JNLNOBIJBACK* = -150380378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1018:9
else:
  let YDB_ERR_JNLNOBIJBACK* = -150380378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1018:9
when -150380387 is static:
  const
    YDB_ERR_SETREG2RESYNC* = -150380387 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1019:9
else:
  let YDB_ERR_SETREG2RESYNC* = -150380387 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1019:9
when -150380392 is static:
  const
    YDB_ERR_JNLALIGNTOOSM* = -150380392 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1020:9
else:
  let YDB_ERR_JNLALIGNTOOSM* = -150380392 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1020:9
when -150380402 is static:
  const
    YDB_ERR_JNLFILEOPNERR* = -150380402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1021:9
else:
  let YDB_ERR_JNLFILEOPNERR* = -150380402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1021:9
when -150380410 is static:
  const
    YDB_ERR_JNLFILECLOSERR* = -150380410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1022:9
else:
  let YDB_ERR_JNLFILECLOSERR* = -150380410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1022:9
when -150380418 is static:
  const
    YDB_ERR_REPLSTATEOFF* = -150380418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1023:9
else:
  let YDB_ERR_REPLSTATEOFF* = -150380418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1023:9
when -150380427 is static:
  const
    YDB_ERR_MUJNLPREVGEN* = -150380427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1024:9
else:
  let YDB_ERR_MUJNLPREVGEN* = -150380427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1024:9
when -150380434 is static:
  const
    YDB_ERR_MUPJNLINTERRUPT* = -150380434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1025:9
else:
  let YDB_ERR_MUPJNLINTERRUPT* = -150380434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1025:9
when -150380442 is static:
  const
    YDB_ERR_ROLLBKINTERRUPT* = -150380442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1026:9
else:
  let YDB_ERR_ROLLBKINTERRUPT* = -150380442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1026:9
when -150380451 is static:
  const
    YDB_ERR_RLBKJNSEQ* = -150380451 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1027:9
else:
  let YDB_ERR_RLBKJNSEQ* = -150380451 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1027:9
when -150380460 is static:
  const
    YDB_ERR_REPLRECFMT* = -150380460 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1028:9
else:
  let YDB_ERR_REPLRECFMT* = -150380460 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1028:9
when -150380466 is static:
  const
    YDB_ERR_PRIMARYNOTROOT* = -150380466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1029:9
else:
  let YDB_ERR_PRIMARYNOTROOT* = -150380466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1029:9
when -150380474 is static:
  const
    YDB_ERR_DBFRZRESETFL* = -150380474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1030:9
else:
  let YDB_ERR_DBFRZRESETFL* = -150380474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1030:9
when -150380482 is static:
  const
    YDB_ERR_JNLCYCLE* = -150380482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1031:9
else:
  let YDB_ERR_JNLCYCLE* = -150380482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1031:9
when -150380490 is static:
  const
    YDB_ERR_JNLPREVRECOV* = -150380490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1032:9
else:
  let YDB_ERR_JNLPREVRECOV* = -150380490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1032:9
when -150380499 is static:
  const
    YDB_ERR_RESOLVESEQNO* = -150380499 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1033:9
else:
  let YDB_ERR_RESOLVESEQNO* = -150380499 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1033:9
when -150380506 is static:
  const
    YDB_ERR_BOVTNGTEOVTN* = -150380506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1034:9
else:
  let YDB_ERR_BOVTNGTEOVTN* = -150380506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1034:9
when -150380514 is static:
  const
    YDB_ERR_BOVTMGTEOVTM* = -150380514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1035:9
else:
  let YDB_ERR_BOVTMGTEOVTM* = -150380514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1035:9
when -150380522 is static:
  const
    YDB_ERR_BEGSEQGTENDSEQ* = -150380522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1036:9
else:
  let YDB_ERR_BEGSEQGTENDSEQ* = -150380522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1036:9
when -150380531 is static:
  const
    YDB_ERR_DBADDRALIGN* = -150380531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1037:9
else:
  let YDB_ERR_DBADDRALIGN* = -150380531 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1037:9
when -150380539 is static:
  const
    YDB_ERR_DBWCVERIFYSTART* = -150380539 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1038:9
else:
  let YDB_ERR_DBWCVERIFYSTART* = -150380539 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1038:9
when -150380547 is static:
  const
    YDB_ERR_DBWCVERIFYEND* = -150380547 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1039:9
else:
  let YDB_ERR_DBWCVERIFYEND* = -150380547 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1039:9
when -150380555 is static:
  const
    YDB_ERR_MUPIPSIG* = -150380555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1040:9
else:
  let YDB_ERR_MUPIPSIG* = -150380555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1040:9
when -150380560 is static:
  const
    YDB_ERR_HTSHRINKFAIL* = -150380560 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1041:9
else:
  let YDB_ERR_HTSHRINKFAIL* = -150380560 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1041:9
when -150380570 is static:
  const
    YDB_ERR_STPEXPFAIL* = -150380570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1042:9
else:
  let YDB_ERR_STPEXPFAIL* = -150380570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1042:9
when -150380576 is static:
  const
    YDB_ERR_DBBTUWRNG* = -150380576 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1043:9
else:
  let YDB_ERR_DBBTUWRNG* = -150380576 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1043:9
when -150380587 is static:
  const
    YDB_ERR_DBBTUFIXED* = -150380587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1044:9
else:
  let YDB_ERR_DBBTUFIXED* = -150380587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1044:9
when -150380594 is static:
  const
    YDB_ERR_DBMAXREC2BIG* = -150380594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1045:9
else:
  let YDB_ERR_DBMAXREC2BIG* = -150380594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1045:9
when -150380602 is static:
  const
    YDB_ERR_UNUSEDMSG1214* = -150380602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1046:9
else:
  let YDB_ERR_UNUSEDMSG1214* = -150380602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1046:9
when -150380610 is static:
  const
    YDB_ERR_UNUSEDMSG1215* = -150380610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1047:9
else:
  let YDB_ERR_UNUSEDMSG1215* = -150380610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1047:9
when -150380618 is static:
  const
    YDB_ERR_UNUSEDMSG1216* = -150380618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1048:9
else:
  let YDB_ERR_UNUSEDMSG1216* = -150380618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1048:9
when -150380626 is static:
  const
    YDB_ERR_UNUSEDMSG1217* = -150380626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1049:9
else:
  let YDB_ERR_UNUSEDMSG1217* = -150380626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1049:9
when -150380634 is static:
  const
    YDB_ERR_DBMINRESBYTES* = -150380634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1050:9
else:
  let YDB_ERR_DBMINRESBYTES* = -150380634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1050:9
when -150380642 is static:
  const
    YDB_ERR_UNUSEDMSG1219* = -150380642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1051:9
else:
  let YDB_ERR_UNUSEDMSG1219* = -150380642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1051:9
when -150380651 is static:
  const
    YDB_ERR_UNUSEDMSG1220* = -150380651 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1052:9
else:
  let YDB_ERR_UNUSEDMSG1220* = -150380651 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1052:9
when -150380658 is static:
  const
    YDB_ERR_UNUSEDMSG1221* = -150380658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1053:9
else:
  let YDB_ERR_UNUSEDMSG1221* = -150380658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1053:9
when -150380666 is static:
  const
    YDB_ERR_UNUSEDMSG1222* = -150380666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1054:9
else:
  let YDB_ERR_UNUSEDMSG1222* = -150380666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1054:9
when -150380674 is static:
  const
    YDB_ERR_UNUSEDMSG1223* = -150380674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1055:9
else:
  let YDB_ERR_UNUSEDMSG1223* = -150380674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1055:9
when -150380682 is static:
  const
    YDB_ERR_UNUSEDMSG1224* = -150380682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1056:9
else:
  let YDB_ERR_UNUSEDMSG1224* = -150380682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1056:9
when -150380690 is static:
  const
    YDB_ERR_UNUSEDMSG1225* = -150380690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1057:9
else:
  let YDB_ERR_UNUSEDMSG1225* = -150380690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1057:9
when -150380698 is static:
  const
    YDB_ERR_DYNUPGRDFAIL* = -150380698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1058:9
else:
  let YDB_ERR_DYNUPGRDFAIL* = -150380698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1058:9
when -150380706 is static:
  const
    YDB_ERR_MMNODYNDWNGRD* = -150380706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1059:9
else:
  let YDB_ERR_MMNODYNDWNGRD* = -150380706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1059:9
when -150380714 is static:
  const
    YDB_ERR_MMNODYNUPGRD* = -150380714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1060:9
else:
  let YDB_ERR_MMNODYNUPGRD* = -150380714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1060:9
when -150380722 is static:
  const
    YDB_ERR_MUDWNGRDNRDY* = -150380722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1061:9
else:
  let YDB_ERR_MUDWNGRDNRDY* = -150380722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1061:9
when -150380730 is static:
  const
    YDB_ERR_MUDWNGRDTN* = -150380730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1062:9
else:
  let YDB_ERR_MUDWNGRDTN* = -150380730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1062:9
when -150380738 is static:
  const
    YDB_ERR_MUDWNGRDNOTPOS* = -150380738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1063:9
else:
  let YDB_ERR_MUDWNGRDNOTPOS* = -150380738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1063:9
when -150380746 is static:
  const
    YDB_ERR_MUUPGRDNRDY* = -150380746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1064:9
else:
  let YDB_ERR_MUUPGRDNRDY* = -150380746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1064:9
when -150380752 is static:
  const
    YDB_ERR_TNWARN* = -150380752 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1065:9
else:
  let YDB_ERR_TNWARN* = -150380752 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1065:9
when -150380762 is static:
  const
    YDB_ERR_TNTOOLARGE* = -150380762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1066:9
else:
  let YDB_ERR_TNTOOLARGE* = -150380762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1066:9
when -150380771 is static:
  const
    YDB_ERR_SHMPLRECOV* = -150380771 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1067:9
else:
  let YDB_ERR_SHMPLRECOV* = -150380771 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1067:9
when -150380776 is static:
  const
    YDB_ERR_MUNOSTRMBKUP* = -150380776 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1068:9
else:
  let YDB_ERR_MUNOSTRMBKUP* = -150380776 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1068:9
when -150380786 is static:
  const
    YDB_ERR_EPOCHTNHI* = -150380786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1069:9
else:
  let YDB_ERR_EPOCHTNHI* = -150380786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1069:9
when -150380795 is static:
  const
    YDB_ERR_CHNGTPRSLVTM* = -150380795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1070:9
else:
  let YDB_ERR_CHNGTPRSLVTM* = -150380795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1070:9
when -150380802 is static:
  const
    YDB_ERR_JNLUNXPCTERR* = -150380802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1071:9
else:
  let YDB_ERR_JNLUNXPCTERR* = -150380802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1071:9
when -150380811 is static:
  const
    YDB_ERR_OMISERVHANG* = -150380811 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1072:9
else:
  let YDB_ERR_OMISERVHANG* = -150380811 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1072:9
when -150380818 is static:
  const
    YDB_ERR_RSVDBYTE2HIGH* = -150380818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1073:9
else:
  let YDB_ERR_RSVDBYTE2HIGH* = -150380818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1073:9
when -418816282 is static:
  const
    YDB_ERR_BKUPTMPFILOPEN* = -418816282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1074:9
else:
  let YDB_ERR_BKUPTMPFILOPEN* = -418816282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1074:9
when -418816290 is static:
  const
    YDB_ERR_BKUPTMPFILWRITE* = -418816290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1075:9
else:
  let YDB_ERR_BKUPTMPFILWRITE* = -418816290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1075:9
when -150380840 is static:
  const
    YDB_ERR_SHMHUGETLB* = -150380840 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1076:9
else:
  let YDB_ERR_SHMHUGETLB* = -150380840 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1076:9
when -150380848 is static:
  const
    YDB_ERR_SHMLOCK* = -150380848 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1077:9
else:
  let YDB_ERR_SHMLOCK* = -150380848 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1077:9
when -150380858 is static:
  const
    YDB_ERR_UNUSEDMSG1246* = -150380858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1078:9
else:
  let YDB_ERR_UNUSEDMSG1246* = -150380858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1078:9
when -150380866 is static:
  const
    YDB_ERR_REPLINSTMISMTCH* = -150380866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1079:9
else:
  let YDB_ERR_REPLINSTMISMTCH* = -150380866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1079:9
when -418816330 is static:
  const
    YDB_ERR_REPLINSTREAD* = -418816330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1080:9
else:
  let YDB_ERR_REPLINSTREAD* = -418816330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1080:9
when -150380882 is static:
  const
    YDB_ERR_REPLINSTDBMATCH* = -150380882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1081:9
else:
  let YDB_ERR_REPLINSTDBMATCH* = -150380882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1081:9
when -150380890 is static:
  const
    YDB_ERR_REPLINSTNMSAME* = -150380890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1082:9
else:
  let YDB_ERR_REPLINSTNMSAME* = -150380890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1082:9
when -150380898 is static:
  const
    YDB_ERR_REPLINSTNMUNDEF* = -150380898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1083:9
else:
  let YDB_ERR_REPLINSTNMUNDEF* = -150380898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1083:9
when -150380906 is static:
  const
    YDB_ERR_REPLINSTNMLEN* = -150380906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1084:9
else:
  let YDB_ERR_REPLINSTNMLEN* = -150380906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1084:9
when -150380914 is static:
  const
    YDB_ERR_REPLINSTNOHIST* = -150380914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1085:9
else:
  let YDB_ERR_REPLINSTNOHIST* = -150380914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1085:9
when -150380922 is static:
  const
    YDB_ERR_REPLINSTSECLEN* = -150380922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1086:9
else:
  let YDB_ERR_REPLINSTSECLEN* = -150380922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1086:9
when -150380930 is static:
  const
    YDB_ERR_REPLINSTSECMTCH* = -150380930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1087:9
else:
  let YDB_ERR_REPLINSTSECMTCH* = -150380930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1087:9
when -150380938 is static:
  const
    YDB_ERR_REPLINSTSECNONE* = -150380938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1088:9
else:
  let YDB_ERR_REPLINSTSECNONE* = -150380938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1088:9
when -150380946 is static:
  const
    YDB_ERR_REPLINSTSECUNDF* = -150380946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1089:9
else:
  let YDB_ERR_REPLINSTSECUNDF* = -150380946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1089:9
when -150380954 is static:
  const
    YDB_ERR_REPLINSTSEQORD* = -150380954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1090:9
else:
  let YDB_ERR_REPLINSTSEQORD* = -150380954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1090:9
when -150380962 is static:
  const
    YDB_ERR_REPLINSTSTNDALN* = -150380962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1091:9
else:
  let YDB_ERR_REPLINSTSTNDALN* = -150380962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1091:9
when -150380970 is static:
  const
    YDB_ERR_REPLREQROLLBACK* = -150380970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1092:9
else:
  let YDB_ERR_REPLREQROLLBACK* = -150380970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1092:9
when -150380978 is static:
  const
    YDB_ERR_REQROLLBACK* = -150380978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1093:9
else:
  let YDB_ERR_REQROLLBACK* = -150380978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1093:9
when -150380986 is static:
  const
    YDB_ERR_INVOBJFILE* = -150380986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1094:9
else:
  let YDB_ERR_INVOBJFILE* = -150380986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1094:9
when -150380994 is static:
  const
    YDB_ERR_SRCSRVEXISTS* = -150380994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1095:9
else:
  let YDB_ERR_SRCSRVEXISTS* = -150380994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1095:9
when -150381002 is static:
  const
    YDB_ERR_SRCSRVNOTEXIST* = -150381002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1096:9
else:
  let YDB_ERR_SRCSRVNOTEXIST* = -150381002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1096:9
when -150381010 is static:
  const
    YDB_ERR_SRCSRVTOOMANY* = -150381010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1097:9
else:
  let YDB_ERR_SRCSRVTOOMANY* = -150381010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1097:9
when -150381016 is static:
  const
    YDB_ERR_JNLPOOLBADSLOT* = -150381016 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1098:9
else:
  let YDB_ERR_JNLPOOLBADSLOT* = -150381016 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1098:9
when -150381026 is static:
  const
    YDB_ERR_NOENDIANCVT* = -150381026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1099:9
else:
  let YDB_ERR_NOENDIANCVT* = -150381026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1099:9
when -150381035 is static:
  const
    YDB_ERR_ENDIANCVT* = -150381035 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1100:9
else:
  let YDB_ERR_ENDIANCVT* = -150381035 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1100:9
when -150381042 is static:
  const
    YDB_ERR_DBENDIAN* = -150381042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1101:9
else:
  let YDB_ERR_DBENDIAN* = -150381042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1101:9
when -150381050 is static:
  const
    YDB_ERR_BADCHSET* = -150381050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1102:9
else:
  let YDB_ERR_BADCHSET* = -150381050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1102:9
when -150381058 is static:
  const
    YDB_ERR_BADCASECODE* = -150381058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1103:9
else:
  let YDB_ERR_BADCASECODE* = -150381058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1103:9
when -150381066 is static:
  const
    YDB_ERR_BADCHAR* = -150381066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1104:9
else:
  let YDB_ERR_BADCHAR* = -150381066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1104:9
when -150381074 is static:
  const
    YDB_ERR_DLRCILLEGAL* = -150381074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1105:9
else:
  let YDB_ERR_DLRCILLEGAL* = -150381074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1105:9
when -150381082 is static:
  const
    YDB_ERR_NONUTF8LOCALE* = -150381082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1106:9
else:
  let YDB_ERR_NONUTF8LOCALE* = -150381082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1106:9
when -150381090 is static:
  const
    YDB_ERR_INVDLRCVAL* = -150381090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1107:9
else:
  let YDB_ERR_INVDLRCVAL* = -150381090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1107:9
when -150381098 is static:
  const
    YDB_ERR_DBMISALIGN* = -150381098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1108:9
else:
  let YDB_ERR_DBMISALIGN* = -150381098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1108:9
when -150381106 is static:
  const
    YDB_ERR_LOADINVCHSET* = -150381106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1109:9
else:
  let YDB_ERR_LOADINVCHSET* = -150381106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1109:9
when -150381114 is static:
  const
    YDB_ERR_DLLCHSETM* = -150381114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1110:9
else:
  let YDB_ERR_DLLCHSETM* = -150381114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1110:9
when -150381122 is static:
  const
    YDB_ERR_DLLCHSETUTF8* = -150381122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1111:9
else:
  let YDB_ERR_DLLCHSETUTF8* = -150381122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1111:9
when -150381130 is static:
  const
    YDB_ERR_BOMMISMATCH* = -150381130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1112:9
else:
  let YDB_ERR_BOMMISMATCH* = -150381130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1112:9
when -150381138 is static:
  const
    YDB_ERR_WIDTHTOOSMALL* = -150381138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1113:9
else:
  let YDB_ERR_WIDTHTOOSMALL* = -150381138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1113:9
when -150381146 is static:
  const
    YDB_ERR_SOCKMAX* = -150381146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1114:9
else:
  let YDB_ERR_SOCKMAX* = -150381146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1114:9
when -150381154 is static:
  const
    YDB_ERR_PADCHARINVALID* = -150381154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1115:9
else:
  let YDB_ERR_PADCHARINVALID* = -150381154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1115:9
when -150381162 is static:
  const
    YDB_ERR_ZCNOPREALLOUTPAR* = -150381162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1116:9
else:
  let YDB_ERR_ZCNOPREALLOUTPAR* = -150381162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1116:9
when -150381170 is static:
  const
    YDB_ERR_SVNEXPECTED* = -150381170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1117:9
else:
  let YDB_ERR_SVNEXPECTED* = -150381170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1117:9
when -150381178 is static:
  const
    YDB_ERR_SVNONEW* = -150381178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1118:9
else:
  let YDB_ERR_SVNONEW* = -150381178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1118:9
when -150381186 is static:
  const
    YDB_ERR_ZINTDIRECT* = -150381186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1119:9
else:
  let YDB_ERR_ZINTDIRECT* = -150381186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1119:9
when -150381194 is static:
  const
    YDB_ERR_ZINTRECURSEIO* = -150381194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1120:9
else:
  let YDB_ERR_ZINTRECURSEIO* = -150381194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1120:9
when -150381202 is static:
  const
    YDB_ERR_MRTMAXEXCEEDED* = -150381202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1121:9
else:
  let YDB_ERR_MRTMAXEXCEEDED* = -150381202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1121:9
when -150381210 is static:
  const
    YDB_ERR_JNLCLOSED* = -150381210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1122:9
else:
  let YDB_ERR_JNLCLOSED* = -150381210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1122:9
when -150381218 is static:
  const
    YDB_ERR_RLBKNOBIMG* = -150381218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1123:9
else:
  let YDB_ERR_RLBKNOBIMG* = -150381218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1123:9
when -150381227 is static:
  const
    YDB_ERR_RLBKJNLNOBIMG* = -150381227 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1124:9
else:
  let YDB_ERR_RLBKJNLNOBIMG* = -150381227 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1124:9
when -150381235 is static:
  const
    YDB_ERR_RLBKLOSTTNONLY* = -150381235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1125:9
else:
  let YDB_ERR_RLBKLOSTTNONLY* = -150381235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1125:9
when -150381244 is static:
  const
    YDB_ERR_KILLBYSIGSINFO3* = -150381244 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1126:9
else:
  let YDB_ERR_KILLBYSIGSINFO3* = -150381244 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1126:9
when -150381251 is static:
  const
    YDB_ERR_GTMSECSHRTMPPATH* = -150381251 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1127:9
else:
  let YDB_ERR_GTMSECSHRTMPPATH* = -150381251 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1127:9
when -150381258 is static:
  const
    YDB_ERR_UNUSEDMSG1296* = -150381258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1128:9
else:
  let YDB_ERR_UNUSEDMSG1296* = -150381258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1128:9
when -150381264 is static:
  const
    YDB_ERR_INVMEMRESRV* = -150381264 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1129:9
else:
  let YDB_ERR_INVMEMRESRV* = -150381264 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1129:9
when -150381275 is static:
  const
    YDB_ERR_OPCOMMISSED* = -150381275 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1130:9
else:
  let YDB_ERR_OPCOMMISSED* = -150381275 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1130:9
when -150381282 is static:
  const
    YDB_ERR_COMMITWAITSTUCK* = -150381282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1131:9
else:
  let YDB_ERR_COMMITWAITSTUCK* = -150381282 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1131:9
when -150381290 is static:
  const
    YDB_ERR_COMMITWAITPID* = -150381290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1132:9
else:
  let YDB_ERR_COMMITWAITPID* = -150381290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1132:9
when -150381298 is static:
  const
    YDB_ERR_UPDREPLSTATEOFF* = -150381298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1133:9
else:
  let YDB_ERR_UPDREPLSTATEOFF* = -150381298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1133:9
when -150381304 is static:
  const
    YDB_ERR_LITNONGRAPH* = -150381304 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1134:9
else:
  let YDB_ERR_LITNONGRAPH* = -150381304 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1134:9
when -150381315 is static:
  const
    YDB_ERR_DBFHEADERR8* = -150381315 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1135:9
else:
  let YDB_ERR_DBFHEADERR8* = -150381315 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1135:9
when -150381320 is static:
  const
    YDB_ERR_MMBEFOREJNL* = -150381320 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1136:9
else:
  let YDB_ERR_MMBEFOREJNL* = -150381320 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1136:9
when -150381328 is static:
  const
    YDB_ERR_MMNOBFORRPL* = -150381328 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1137:9
else:
  let YDB_ERR_MMNOBFORRPL* = -150381328 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1137:9
when -150381336 is static:
  const
    YDB_ERR_KILLABANDONED* = -150381336 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1138:9
else:
  let YDB_ERR_KILLABANDONED* = -150381336 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1138:9
when -150381344 is static:
  const
    YDB_ERR_BACKUPKILLIP* = -150381344 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1139:9
else:
  let YDB_ERR_BACKUPKILLIP* = -150381344 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1139:9
when -150381354 is static:
  const
    YDB_ERR_LOGTOOLONG* = -150381354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1140:9
else:
  let YDB_ERR_LOGTOOLONG* = -150381354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1140:9
when -150381362 is static:
  const
    YDB_ERR_NOALIASLIST* = -150381362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1141:9
else:
  let YDB_ERR_NOALIASLIST* = -150381362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1141:9
when -150381370 is static:
  const
    YDB_ERR_ALIASEXPECTED* = -150381370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1142:9
else:
  let YDB_ERR_ALIASEXPECTED* = -150381370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1142:9
when -150381378 is static:
  const
    YDB_ERR_VIEWLVN* = -150381378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1143:9
else:
  let YDB_ERR_VIEWLVN* = -150381378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1143:9
when -150381386 is static:
  const
    YDB_ERR_DZWRNOPAREN* = -150381386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1144:9
else:
  let YDB_ERR_DZWRNOPAREN* = -150381386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1144:9
when -150381394 is static:
  const
    YDB_ERR_DZWRNOALIAS* = -150381394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1145:9
else:
  let YDB_ERR_DZWRNOALIAS* = -150381394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1145:9
when -150381402 is static:
  const
    YDB_ERR_FREEZEERR* = -150381402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1146:9
else:
  let YDB_ERR_FREEZEERR* = -150381402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1146:9
when -150381410 is static:
  const
    YDB_ERR_CLOSEFAIL* = -150381410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1147:9
else:
  let YDB_ERR_CLOSEFAIL* = -150381410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1147:9
when -150381418 is static:
  const
    YDB_ERR_CRYPTINIT* = -150381418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1148:9
else:
  let YDB_ERR_CRYPTINIT* = -150381418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1148:9
when -150381426 is static:
  const
    YDB_ERR_CRYPTOPFAILED* = -150381426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1149:9
else:
  let YDB_ERR_CRYPTOPFAILED* = -150381426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1149:9
when -150381434 is static:
  const
    YDB_ERR_CRYPTDLNOOPEN* = -150381434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1150:9
else:
  let YDB_ERR_CRYPTDLNOOPEN* = -150381434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1150:9
when -150381442 is static:
  const
    YDB_ERR_CRYPTNOV4* = -150381442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1151:9
else:
  let YDB_ERR_CRYPTNOV4* = -150381442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1151:9
when -150381450 is static:
  const
    YDB_ERR_CRYPTNOMM* = -150381450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1152:9
else:
  let YDB_ERR_CRYPTNOMM* = -150381450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1152:9
when -150381458 is static:
  const
    YDB_ERR_READONLYNOBG* = -150381458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1153:9
else:
  let YDB_ERR_READONLYNOBG* = -150381458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1153:9
when -418816922 is static:
  const
    YDB_ERR_CRYPTKEYFETCHFAILED* = -418816922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1154:9
else:
  let YDB_ERR_CRYPTKEYFETCHFAILED* = -418816922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1154:9
when -150381474 is static:
  const
    YDB_ERR_CRYPTKEYFETCHFAILEDNF* = -150381474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1155:9
else:
  let YDB_ERR_CRYPTKEYFETCHFAILEDNF* = -150381474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1155:9
when -150381482 is static:
  const
    YDB_ERR_CRYPTHASHGENFAILED* = -150381482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1156:9
else:
  let YDB_ERR_CRYPTHASHGENFAILED* = -150381482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1156:9
when -150381490 is static:
  const
    YDB_ERR_CRYPTNOKEY* = -150381490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1157:9
else:
  let YDB_ERR_CRYPTNOKEY* = -150381490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1157:9
when -150381498 is static:
  const
    YDB_ERR_BADTAG* = -150381498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1158:9
else:
  let YDB_ERR_BADTAG* = -150381498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1158:9
when -150381506 is static:
  const
    YDB_ERR_ICUVERLT36* = -150381506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1159:9
else:
  let YDB_ERR_ICUVERLT36* = -150381506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1159:9
when -150381514 is static:
  const
    YDB_ERR_ICUSYMNOTFOUND* = -150381514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1160:9
else:
  let YDB_ERR_ICUSYMNOTFOUND* = -150381514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1160:9
when -150381523 is static:
  const
    YDB_ERR_STUCKACT* = -150381523 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1161:9
else:
  let YDB_ERR_STUCKACT* = -150381523 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1161:9
when -150381530 is static:
  const
    YDB_ERR_CALLINAFTERXIT* = -150381530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1162:9
else:
  let YDB_ERR_CALLINAFTERXIT* = -150381530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1162:9
when -150381538 is static:
  const
    YDB_ERR_LOCKSPACEFULL* = -150381538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1163:9
else:
  let YDB_ERR_LOCKSPACEFULL* = -150381538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1163:9
when -150381546 is static:
  const
    YDB_ERR_IOERROR* = -150381546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1164:9
else:
  let YDB_ERR_IOERROR* = -150381546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1164:9
when -150381554 is static:
  const
    YDB_ERR_MAXSSREACHED* = -150381554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1165:9
else:
  let YDB_ERR_MAXSSREACHED* = -150381554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1165:9
when -150381562 is static:
  const
    YDB_ERR_SNAPSHOTNOV4* = -150381562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1166:9
else:
  let YDB_ERR_SNAPSHOTNOV4* = -150381562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1166:9
when -150381570 is static:
  const
    YDB_ERR_SSV4NOALLOW* = -150381570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1167:9
else:
  let YDB_ERR_SSV4NOALLOW* = -150381570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1167:9
when -418817034 is static:
  const
    YDB_ERR_SSTMPDIRSTAT* = -418817034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1168:9
else:
  let YDB_ERR_SSTMPDIRSTAT* = -418817034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1168:9
when -418817042 is static:
  const
    YDB_ERR_SSTMPCREATE* = -418817042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1169:9
else:
  let YDB_ERR_SSTMPCREATE* = -418817042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1169:9
when -150381594 is static:
  const
    YDB_ERR_JNLFILEDUP* = -150381594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1170:9
else:
  let YDB_ERR_JNLFILEDUP* = -150381594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1170:9
when -150381602 is static:
  const
    YDB_ERR_SSPREMATEOF* = -150381602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1171:9
else:
  let YDB_ERR_SSPREMATEOF* = -150381602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1171:9
when -150381610 is static:
  const
    YDB_ERR_SSFILOPERR* = -150381610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1172:9
else:
  let YDB_ERR_SSFILOPERR* = -150381610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1172:9
when -150381618 is static:
  const
    YDB_ERR_REGSSFAIL* = -150381618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1173:9
else:
  let YDB_ERR_REGSSFAIL* = -150381618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1173:9
when -150381626 is static:
  const
    YDB_ERR_SSSHMCLNUPFAIL* = -150381626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1174:9
else:
  let YDB_ERR_SSSHMCLNUPFAIL* = -150381626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1174:9
when -150381634 is static:
  const
    YDB_ERR_SSFILCLNUPFAIL* = -150381634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1175:9
else:
  let YDB_ERR_SSFILCLNUPFAIL* = -150381634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1175:9
when -150381642 is static:
  const
    YDB_ERR_SETINTRIGONLY* = -150381642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1176:9
else:
  let YDB_ERR_SETINTRIGONLY* = -150381642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1176:9
when -150381650 is static:
  const
    YDB_ERR_MAXTRIGNEST* = -150381650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1177:9
else:
  let YDB_ERR_MAXTRIGNEST* = -150381650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1177:9
when -150381658 is static:
  const
    YDB_ERR_TRIGCOMPFAIL* = -150381658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1178:9
else:
  let YDB_ERR_TRIGCOMPFAIL* = -150381658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1178:9
when -150381666 is static:
  const
    YDB_ERR_NOZTRAPINTRIG* = -150381666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1179:9
else:
  let YDB_ERR_NOZTRAPINTRIG* = -150381666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1179:9
when -150381674 is static:
  const
    YDB_ERR_ZTWORMHOLE2BIG* = -150381674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1180:9
else:
  let YDB_ERR_ZTWORMHOLE2BIG* = -150381674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1180:9
when -150381682 is static:
  const
    YDB_ERR_JNLENDIANLITTLE* = -150381682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1181:9
else:
  let YDB_ERR_JNLENDIANLITTLE* = -150381682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1181:9
when -150381690 is static:
  const
    YDB_ERR_JNLENDIANBIG* = -150381690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1182:9
else:
  let YDB_ERR_JNLENDIANBIG* = -150381690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1182:9
when -150381698 is static:
  const
    YDB_ERR_TRIGINVCHSET* = -150381698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1183:9
else:
  let YDB_ERR_TRIGINVCHSET* = -150381698 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1183:9
when -150381706 is static:
  const
    YDB_ERR_TRIGREPLSTATE* = -150381706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1184:9
else:
  let YDB_ERR_TRIGREPLSTATE* = -150381706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1184:9
when -150381714 is static:
  const
    YDB_ERR_GVDATAGETFAIL* = -150381714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1185:9
else:
  let YDB_ERR_GVDATAGETFAIL* = -150381714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1185:9
when -150381720 is static:
  const
    YDB_ERR_TRIG2NOTRIG* = -150381720 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1186:9
else:
  let YDB_ERR_TRIG2NOTRIG* = -150381720 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1186:9
when -150381730 is static:
  const
    YDB_ERR_ZGOTOINVLVL* = -150381730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1187:9
else:
  let YDB_ERR_ZGOTOINVLVL* = -150381730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1187:9
when -150381738 is static:
  const
    YDB_ERR_TRIGTCOMMIT* = -150381738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1188:9
else:
  let YDB_ERR_TRIGTCOMMIT* = -150381738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1188:9
when -150381746 is static:
  const
    YDB_ERR_TRIGTLVLCHNG* = -150381746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1189:9
else:
  let YDB_ERR_TRIGTLVLCHNG* = -150381746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1189:9
when -150381754 is static:
  const
    YDB_ERR_TRIGNAMEUNIQ* = -150381754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1190:9
else:
  let YDB_ERR_TRIGNAMEUNIQ* = -150381754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1190:9
when -150381762 is static:
  const
    YDB_ERR_ZTRIGINVACT* = -150381762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1191:9
else:
  let YDB_ERR_ZTRIGINVACT* = -150381762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1191:9
when -150381770 is static:
  const
    YDB_ERR_INDRCOMPFAIL* = -150381770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1192:9
else:
  let YDB_ERR_INDRCOMPFAIL* = -150381770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1192:9
when -150381778 is static:
  const
    YDB_ERR_QUITALSINV* = -150381778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1193:9
else:
  let YDB_ERR_QUITALSINV* = -150381778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1193:9
when -150381784 is static:
  const
    YDB_ERR_PROCTERM* = -150381784 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1194:9
else:
  let YDB_ERR_PROCTERM* = -150381784 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1194:9
when -150381795 is static:
  const
    YDB_ERR_SRCLNNTDSP* = -150381795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1195:9
else:
  let YDB_ERR_SRCLNNTDSP* = -150381795 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1195:9
when -150381803 is static:
  const
    YDB_ERR_ARROWNTDSP* = -150381803 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1196:9
else:
  let YDB_ERR_ARROWNTDSP* = -150381803 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1196:9
when -150381810 is static:
  const
    YDB_ERR_TRIGDEFBAD* = -150381810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1197:9
else:
  let YDB_ERR_TRIGDEFBAD* = -150381810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1197:9
when -150381818 is static:
  const
    YDB_ERR_TRIGSUBSCRANGE* = -150381818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1198:9
else:
  let YDB_ERR_TRIGSUBSCRANGE* = -150381818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1198:9
when -150381827 is static:
  const
    YDB_ERR_TRIGDATAIGNORE* = -150381827 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1199:9
else:
  let YDB_ERR_TRIGDATAIGNORE* = -150381827 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1199:9
when -150381835 is static:
  const
    YDB_ERR_TRIGIS* = -150381835 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1200:9
else:
  let YDB_ERR_TRIGIS* = -150381835 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1200:9
when -150381842 is static:
  const
    YDB_ERR_TCOMMITDISALLOW* = -150381842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1201:9
else:
  let YDB_ERR_TCOMMITDISALLOW* = -150381842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1201:9
when -150381850 is static:
  const
    YDB_ERR_SSATTACHSHM* = -150381850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1202:9
else:
  let YDB_ERR_SSATTACHSHM* = -150381850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1202:9
when -150381856 is static:
  const
    YDB_ERR_TRIGDEFNOSYNC* = -150381856 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1203:9
else:
  let YDB_ERR_TRIGDEFNOSYNC* = -150381856 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1203:9
when -150381866 is static:
  const
    YDB_ERR_TRESTMAX* = -150381866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1204:9
else:
  let YDB_ERR_TRESTMAX* = -150381866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1204:9
when -150381875 is static:
  const
    YDB_ERR_ZLINKBYPASS* = -150381875 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1205:9
else:
  let YDB_ERR_ZLINKBYPASS* = -150381875 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1205:9
when -150381882 is static:
  const
    YDB_ERR_GBLEXPECTED* = -150381882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1206:9
else:
  let YDB_ERR_GBLEXPECTED* = -150381882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1206:9
when -150381890 is static:
  const
    YDB_ERR_GVZTRIGFAIL* = -150381890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1207:9
else:
  let YDB_ERR_GVZTRIGFAIL* = -150381890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1207:9
when -150381898 is static:
  const
    YDB_ERR_MUUSERLBK* = -150381898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1208:9
else:
  let YDB_ERR_MUUSERLBK* = -150381898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1208:9
when -150381906 is static:
  const
    YDB_ERR_SETINSETTRIGONLY* = -150381906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1209:9
else:
  let YDB_ERR_SETINSETTRIGONLY* = -150381906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1209:9
when -150381914 is static:
  const
    YDB_ERR_DZTRIGINTRIG* = -150381914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1210:9
else:
  let YDB_ERR_DZTRIGINTRIG* = -150381914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1210:9
when -150381920 is static:
  const
    YDB_ERR_LSINSERTED* = -150381920 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1211:9
else:
  let YDB_ERR_LSINSERTED* = -150381920 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1211:9
when -150381928 is static:
  const
    YDB_ERR_BOOLSIDEFFECT* = -150381928 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1212:9
else:
  let YDB_ERR_BOOLSIDEFFECT* = -150381928 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1212:9
when -150381936 is static:
  const
    YDB_ERR_DBBADUPGRDSTATE* = -150381936 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1213:9
else:
  let YDB_ERR_DBBADUPGRDSTATE* = -150381936 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1213:9
when -150381946 is static:
  const
    YDB_ERR_WRITEWAITPID* = -150381946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1214:9
else:
  let YDB_ERR_WRITEWAITPID* = -150381946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1214:9
when -150381954 is static:
  const
    YDB_ERR_ZGOCALLOUTIN* = -150381954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1215:9
else:
  let YDB_ERR_ZGOCALLOUTIN* = -150381954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1215:9
when -150381962 is static:
  const
    YDB_ERR_UNUSEDMSG1384* = -150381962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1216:9
else:
  let YDB_ERR_UNUSEDMSG1384* = -150381962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1216:9
when -150381970 is static:
  const
    YDB_ERR_REPLXENDIANFAIL* = -150381970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1217:9
else:
  let YDB_ERR_REPLXENDIANFAIL* = -150381970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1217:9
when -150381978 is static:
  const
    YDB_ERR_UNUSEDMSG1386* = -150381978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1218:9
else:
  let YDB_ERR_UNUSEDMSG1386* = -150381978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1218:9
when -150381986 is static:
  const
    YDB_ERR_GTMSECSHRCHDIRF* = -150381986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1219:9
else:
  let YDB_ERR_GTMSECSHRCHDIRF* = -150381986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1219:9
when -418817450 is static:
  const
    YDB_ERR_JNLORDBFLU* = -418817450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1220:9
else:
  let YDB_ERR_JNLORDBFLU* = -418817450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1220:9
when -150382002 is static:
  const
    YDB_ERR_ZCCLNUPRTNMISNG* = -150382002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1221:9
else:
  let YDB_ERR_ZCCLNUPRTNMISNG* = -150382002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1221:9
when -150382010 is static:
  const
    YDB_ERR_ZCINVALIDKEYWORD* = -150382010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1222:9
else:
  let YDB_ERR_ZCINVALIDKEYWORD* = -150382010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1222:9
when -150382018 is static:
  const
    YDB_ERR_REPLMULTINSTUPDATE* = -150382018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1223:9
else:
  let YDB_ERR_REPLMULTINSTUPDATE* = -150382018 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1223:9
when -150382026 is static:
  const
    YDB_ERR_DBSHMNAMEDIFF* = -150382026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1224:9
else:
  let YDB_ERR_DBSHMNAMEDIFF* = -150382026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1224:9
when -150382035 is static:
  const
    YDB_ERR_SHMREMOVED* = -150382035 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1225:9
else:
  let YDB_ERR_SHMREMOVED* = -150382035 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1225:9
when -150382042 is static:
  const
    YDB_ERR_DEVICEWRITEONLY* = -150382042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1226:9
else:
  let YDB_ERR_DEVICEWRITEONLY* = -150382042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1226:9
when -150382050 is static:
  const
    YDB_ERR_ICUERROR* = -150382050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1227:9
else:
  let YDB_ERR_ICUERROR* = -150382050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1227:9
when -150382058 is static:
  const
    YDB_ERR_ZDATEBADDATE* = -150382058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1228:9
else:
  let YDB_ERR_ZDATEBADDATE* = -150382058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1228:9
when -150382066 is static:
  const
    YDB_ERR_ZDATEBADTIME* = -150382066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1229:9
else:
  let YDB_ERR_ZDATEBADTIME* = -150382066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1229:9
when -150382074 is static:
  const
    YDB_ERR_COREINPROGRESS* = -150382074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1230:9
else:
  let YDB_ERR_COREINPROGRESS* = -150382074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1230:9
when -150382082 is static:
  const
    YDB_ERR_MAXSEMGETRETRY* = -150382082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1231:9
else:
  let YDB_ERR_MAXSEMGETRETRY* = -150382082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1231:9
when -150382090 is static:
  const
    YDB_ERR_JNLNOREPL* = -150382090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1232:9
else:
  let YDB_ERR_JNLNOREPL* = -150382090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1232:9
when -150382098 is static:
  const
    YDB_ERR_JNLRECINCMPL* = -150382098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1233:9
else:
  let YDB_ERR_JNLRECINCMPL* = -150382098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1233:9
when -150382107 is static:
  const
    YDB_ERR_JNLALLOCGROW* = -150382107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1234:9
else:
  let YDB_ERR_JNLALLOCGROW* = -150382107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1234:9
when -150382114 is static:
  const
    YDB_ERR_INVTRCGRP* = -150382114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1235:9
else:
  let YDB_ERR_INVTRCGRP* = -150382114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1235:9
when -150382123 is static:
  const
    YDB_ERR_MUINFOUINT6* = -150382123 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1236:9
else:
  let YDB_ERR_MUINFOUINT6* = -150382123 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1236:9
when -150382131 is static:
  const
    YDB_ERR_NOLOCKMATCH* = -150382131 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1237:9
else:
  let YDB_ERR_NOLOCKMATCH* = -150382131 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1237:9
when -150382138 is static:
  const
    YDB_ERR_BADREGION* = -150382138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1238:9
else:
  let YDB_ERR_BADREGION* = -150382138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1238:9
when -150382147 is static:
  const
    YDB_ERR_LOCKSPACEUSE* = -150382147 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1239:9
else:
  let YDB_ERR_LOCKSPACEUSE* = -150382147 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1239:9
when -150382154 is static:
  const
    YDB_ERR_JIUNHNDINT* = -150382154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1240:9
else:
  let YDB_ERR_JIUNHNDINT* = -150382154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1240:9
when -150382164 is static:
  const
    YDB_ERR_GTMASSERT2* = -150382164 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1241:9
else:
  let YDB_ERR_GTMASSERT2* = -150382164 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1241:9
when -418817626 is static:
  const
    YDB_ERR_ZTRIGNOTRW* = -418817626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1242:9
else:
  let YDB_ERR_ZTRIGNOTRW* = -418817626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1242:9
when -418817634 is static:
  const
    YDB_ERR_TRIGMODREGNOTRW* = -418817634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1243:9
else:
  let YDB_ERR_TRIGMODREGNOTRW* = -418817634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1243:9
when -150382186 is static:
  const
    YDB_ERR_INSNOTJOINED* = -150382186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1244:9
else:
  let YDB_ERR_INSNOTJOINED* = -150382186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1244:9
when -150382194 is static:
  const
    YDB_ERR_INSROLECHANGE* = -150382194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1245:9
else:
  let YDB_ERR_INSROLECHANGE* = -150382194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1245:9
when -150382202 is static:
  const
    YDB_ERR_INSUNKNOWN* = -150382202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1246:9
else:
  let YDB_ERR_INSUNKNOWN* = -150382202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1246:9
when -150382210 is static:
  const
    YDB_ERR_NORESYNCSUPPLONLY* = -150382210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1247:9
else:
  let YDB_ERR_NORESYNCSUPPLONLY* = -150382210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1247:9
when -150382218 is static:
  const
    YDB_ERR_NORESYNCUPDATERONLY* = -150382218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1248:9
else:
  let YDB_ERR_NORESYNCUPDATERONLY* = -150382218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1248:9
when -150382226 is static:
  const
    YDB_ERR_NOSUPPLSUPPL* = -150382226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1249:9
else:
  let YDB_ERR_NOSUPPLSUPPL* = -150382226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1249:9
when -150382234 is static:
  const
    YDB_ERR_REPL2OLD* = -150382234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1250:9
else:
  let YDB_ERR_REPL2OLD* = -150382234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1250:9
when -150382242 is static:
  const
    YDB_ERR_EXTRFILEXISTS* = -150382242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1251:9
else:
  let YDB_ERR_EXTRFILEXISTS* = -150382242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1251:9
when -150382250 is static:
  const
    YDB_ERR_MUUSERECOV* = -150382250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1252:9
else:
  let YDB_ERR_MUUSERECOV* = -150382250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1252:9
when -150382258 is static:
  const
    YDB_ERR_SECNOTSUPPLEMENTARY* = -150382258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1253:9
else:
  let YDB_ERR_SECNOTSUPPLEMENTARY* = -150382258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1253:9
when -150382266 is static:
  const
    YDB_ERR_SUPRCVRNEEDSSUPSRC* = -150382266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1254:9
else:
  let YDB_ERR_SUPRCVRNEEDSSUPSRC* = -150382266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1254:9
when -150382274 is static:
  const
    YDB_ERR_PEERPIDMISMATCH* = -150382274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1255:9
else:
  let YDB_ERR_PEERPIDMISMATCH* = -150382274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1255:9
when -150382284 is static:
  const
    YDB_ERR_SETITIMERFAILED* = -150382284 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1256:9
else:
  let YDB_ERR_SETITIMERFAILED* = -150382284 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1256:9
when -150382290 is static:
  const
    YDB_ERR_UPDSYNC2MTINS* = -150382290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1257:9
else:
  let YDB_ERR_UPDSYNC2MTINS* = -150382290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1257:9
when -150382298 is static:
  const
    YDB_ERR_UPDSYNCINSTFILE* = -150382298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1258:9
else:
  let YDB_ERR_UPDSYNCINSTFILE* = -150382298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1258:9
when -150382306 is static:
  const
    YDB_ERR_REUSEINSTNAME* = -150382306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1259:9
else:
  let YDB_ERR_REUSEINSTNAME* = -150382306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1259:9
when -150382314 is static:
  const
    YDB_ERR_RCVRMANYSTRMS* = -150382314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1260:9
else:
  let YDB_ERR_RCVRMANYSTRMS* = -150382314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1260:9
when -150382322 is static:
  const
    YDB_ERR_RSYNCSTRMVAL* = -150382322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1261:9
else:
  let YDB_ERR_RSYNCSTRMVAL* = -150382322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1261:9
when -150382331 is static:
  const
    YDB_ERR_RLBKSTRMSEQ* = -150382331 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1262:9
else:
  let YDB_ERR_RLBKSTRMSEQ* = -150382331 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1262:9
when -150382339 is static:
  const
    YDB_ERR_RESOLVESEQSTRM* = -150382339 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1263:9
else:
  let YDB_ERR_RESOLVESEQSTRM* = -150382339 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1263:9
when -150382346 is static:
  const
    YDB_ERR_REPLINSTDBSTRM* = -150382346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1264:9
else:
  let YDB_ERR_REPLINSTDBSTRM* = -150382346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1264:9
when -150382354 is static:
  const
    YDB_ERR_RESUMESTRMNUM* = -150382354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1265:9
else:
  let YDB_ERR_RESUMESTRMNUM* = -150382354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1265:9
when -150382363 is static:
  const
    YDB_ERR_ORLBKSTART* = -150382363 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1266:9
else:
  let YDB_ERR_ORLBKSTART* = -150382363 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1266:9
when -150382370 is static:
  const
    YDB_ERR_ORLBKTERMNTD* = -150382370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1267:9
else:
  let YDB_ERR_ORLBKTERMNTD* = -150382370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1267:9
when -150382379 is static:
  const
    YDB_ERR_ORLBKCMPLT* = -150382379 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1268:9
else:
  let YDB_ERR_ORLBKCMPLT* = -150382379 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1268:9
when -150382387 is static:
  const
    YDB_ERR_ORLBKNOSTP* = -150382387 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1269:9
else:
  let YDB_ERR_ORLBKNOSTP* = -150382387 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1269:9
when -150382395 is static:
  const
    YDB_ERR_ORLBKFRZPROG* = -150382395 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1270:9
else:
  let YDB_ERR_ORLBKFRZPROG* = -150382395 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1270:9
when -150382403 is static:
  const
    YDB_ERR_ORLBKFRZOVER* = -150382403 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1271:9
else:
  let YDB_ERR_ORLBKFRZOVER* = -150382403 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1271:9
when -150382410 is static:
  const
    YDB_ERR_ORLBKNOV4BLK* = -150382410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1272:9
else:
  let YDB_ERR_ORLBKNOV4BLK* = -150382410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1272:9
when -150382418 is static:
  const
    YDB_ERR_DBROLLEDBACK* = -150382418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1273:9
else:
  let YDB_ERR_DBROLLEDBACK* = -150382418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1273:9
when -150382427 is static:
  const
    YDB_ERR_DSEWCREINIT* = -150382427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1274:9
else:
  let YDB_ERR_DSEWCREINIT* = -150382427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1274:9
when -150382435 is static:
  const
    YDB_ERR_MURNDWNOVRD* = -150382435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1275:9
else:
  let YDB_ERR_MURNDWNOVRD* = -150382435 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1275:9
when -150382442 is static:
  const
    YDB_ERR_REPLONLNRLBK* = -150382442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1276:9
else:
  let YDB_ERR_REPLONLNRLBK* = -150382442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1276:9
when -150382450 is static:
  const
    YDB_ERR_SRVLCKWT2LNG* = -150382450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1277:9
else:
  let YDB_ERR_SRVLCKWT2LNG* = -150382450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1277:9
when -150382459 is static:
  const
    YDB_ERR_IGNBMPMRKFREE* = -150382459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1278:9
else:
  let YDB_ERR_IGNBMPMRKFREE* = -150382459 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1278:9
when -418817922 is static:
  const
    YDB_ERR_PERMGENFAIL* = -418817922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1279:9
else:
  let YDB_ERR_PERMGENFAIL* = -418817922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1279:9
when -150382475 is static:
  const
    YDB_ERR_PERMGENDIAG* = -150382475 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1280:9
else:
  let YDB_ERR_PERMGENDIAG* = -150382475 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1280:9
when -150382483 is static:
  const
    YDB_ERR_MUTRUNC1ATIME* = -150382483 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1281:9
else:
  let YDB_ERR_MUTRUNC1ATIME* = -150382483 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1281:9
when -150382491 is static:
  const
    YDB_ERR_MUTRUNCBACKINPROG* = -150382491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1282:9
else:
  let YDB_ERR_MUTRUNCBACKINPROG* = -150382491 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1282:9
when -150382498 is static:
  const
    YDB_ERR_MUTRUNCERROR* = -150382498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1283:9
else:
  let YDB_ERR_MUTRUNCERROR* = -150382498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1283:9
when -150382506 is static:
  const
    YDB_ERR_MUTRUNCFAIL* = -150382506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1284:9
else:
  let YDB_ERR_MUTRUNCFAIL* = -150382506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1284:9
when -150382515 is static:
  const
    YDB_ERR_MUTRUNCNOSPACE* = -150382515 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1285:9
else:
  let YDB_ERR_MUTRUNCNOSPACE* = -150382515 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1285:9
when -150382522 is static:
  const
    YDB_ERR_MUTRUNCNOTBG* = -150382522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1286:9
else:
  let YDB_ERR_MUTRUNCNOTBG* = -150382522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1286:9
when -150382532 is static:
  const
    YDB_ERR_MUTRUNCNOV4* = -150382532 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1287:9
else:
  let YDB_ERR_MUTRUNCNOV4* = -150382532 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1287:9
when -150382538 is static:
  const
    YDB_ERR_MUTRUNCPERCENT* = -150382538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1288:9
else:
  let YDB_ERR_MUTRUNCPERCENT* = -150382538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1288:9
when -150382547 is static:
  const
    YDB_ERR_MUTRUNCSSINPROG* = -150382547 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1289:9
else:
  let YDB_ERR_MUTRUNCSSINPROG* = -150382547 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1289:9
when -150382555 is static:
  const
    YDB_ERR_MUTRUNCSUCCESS* = -150382555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1290:9
else:
  let YDB_ERR_MUTRUNCSUCCESS* = -150382555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1290:9
when -150382562 is static:
  const
    YDB_ERR_RSYNCSTRMSUPPLONLY* = -150382562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1291:9
else:
  let YDB_ERR_RSYNCSTRMSUPPLONLY* = -150382562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1291:9
when -150382571 is static:
  const
    YDB_ERR_STRMNUMIS* = -150382571 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1292:9
else:
  let YDB_ERR_STRMNUMIS* = -150382571 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1292:9
when -150382578 is static:
  const
    YDB_ERR_STRMNUMMISMTCH1* = -150382578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1293:9
else:
  let YDB_ERR_STRMNUMMISMTCH1* = -150382578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1293:9
when -150382586 is static:
  const
    YDB_ERR_STRMNUMMISMTCH2* = -150382586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1294:9
else:
  let YDB_ERR_STRMNUMMISMTCH2* = -150382586 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1294:9
when -150382594 is static:
  const
    YDB_ERR_STRMSEQMISMTCH* = -150382594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1295:9
else:
  let YDB_ERR_STRMSEQMISMTCH* = -150382594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1295:9
when -150382603 is static:
  const
    YDB_ERR_LOCKSPACEINFO* = -150382603 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1296:9
else:
  let YDB_ERR_LOCKSPACEINFO* = -150382603 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1296:9
when -150382610 is static:
  const
    YDB_ERR_JRTNULLFAIL* = -150382610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1297:9
else:
  let YDB_ERR_JRTNULLFAIL* = -150382610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1297:9
when -150382618 is static:
  const
    YDB_ERR_LOCKSUB2LONG* = -150382618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1298:9
else:
  let YDB_ERR_LOCKSUB2LONG* = -150382618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1298:9
when -150382627 is static:
  const
    YDB_ERR_RESRCWAIT* = -150382627 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1299:9
else:
  let YDB_ERR_RESRCWAIT* = -150382627 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1299:9
when -150382635 is static:
  const
    YDB_ERR_RESRCINTRLCKBYPAS* = -150382635 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1300:9
else:
  let YDB_ERR_RESRCINTRLCKBYPAS* = -150382635 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1300:9
when -150382643 is static:
  const
    YDB_ERR_DBFHEADERRANY* = -150382643 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1301:9
else:
  let YDB_ERR_DBFHEADERRANY* = -150382643 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1301:9
when -150382650 is static:
  const
    YDB_ERR_REPLINSTFROZEN* = -150382650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1302:9
else:
  let YDB_ERR_REPLINSTFROZEN* = -150382650 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1302:9
when -150382659 is static:
  const
    YDB_ERR_REPLINSTFREEZECOMMENT* = -150382659 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1303:9
else:
  let YDB_ERR_REPLINSTFREEZECOMMENT* = -150382659 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1303:9
when -150382667 is static:
  const
    YDB_ERR_REPLINSTUNFROZEN* = -150382667 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1304:9
else:
  let YDB_ERR_REPLINSTUNFROZEN* = -150382667 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1304:9
when -150382675 is static:
  const
    YDB_ERR_DSKNOSPCAVAIL* = -150382675 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1305:9
else:
  let YDB_ERR_DSKNOSPCAVAIL* = -150382675 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1305:9
when -150382682 is static:
  const
    YDB_ERR_DSKNOSPCBLOCKED* = -150382682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1306:9
else:
  let YDB_ERR_DSKNOSPCBLOCKED* = -150382682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1306:9
when -150382691 is static:
  const
    YDB_ERR_DSKSPCAVAILABLE* = -150382691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1307:9
else:
  let YDB_ERR_DSKSPCAVAILABLE* = -150382691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1307:9
when -150382699 is static:
  const
    YDB_ERR_ENOSPCQIODEFER* = -150382699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1308:9
else:
  let YDB_ERR_ENOSPCQIODEFER* = -150382699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1308:9
when -150382706 is static:
  const
    YDB_ERR_CUSTOMFILOPERR* = -150382706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1309:9
else:
  let YDB_ERR_CUSTOMFILOPERR* = -150382706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1309:9
when -150382714 is static:
  const
    YDB_ERR_CUSTERRNOTFND* = -150382714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1310:9
else:
  let YDB_ERR_CUSTERRNOTFND* = -150382714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1310:9
when -150382722 is static:
  const
    YDB_ERR_CUSTERRSYNTAX* = -150382722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1311:9
else:
  let YDB_ERR_CUSTERRSYNTAX* = -150382722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1311:9
when -150382731 is static:
  const
    YDB_ERR_ORLBKINPROG* = -150382731 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1312:9
else:
  let YDB_ERR_ORLBKINPROG* = -150382731 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1312:9
when -150382738 is static:
  const
    YDB_ERR_DBSPANGLOINCMP* = -150382738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1313:9
else:
  let YDB_ERR_DBSPANGLOINCMP* = -150382738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1313:9
when -150382746 is static:
  const
    YDB_ERR_DBSPANCHUNKORD* = -150382746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1314:9
else:
  let YDB_ERR_DBSPANCHUNKORD* = -150382746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1314:9
when -150382754 is static:
  const
    YDB_ERR_DBDATAMX* = -150382754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1315:9
else:
  let YDB_ERR_DBDATAMX* = -150382754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1315:9
when -150382762 is static:
  const
    YDB_ERR_DBIOERR* = -150382762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1316:9
else:
  let YDB_ERR_DBIOERR* = -150382762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1316:9
when -150382770 is static:
  const
    YDB_ERR_INITORRESUME* = -150382770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1317:9
else:
  let YDB_ERR_INITORRESUME* = -150382770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1317:9
when -150382780 is static:
  const
    YDB_ERR_GTMSECSHRNOARG0* = -150382780 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1318:9
else:
  let YDB_ERR_GTMSECSHRNOARG0* = -150382780 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1318:9
when -150382788 is static:
  const
    YDB_ERR_GTMSECSHRISNOT* = -150382788 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1319:9
else:
  let YDB_ERR_GTMSECSHRISNOT* = -150382788 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1319:9
when -150382796 is static:
  const
    YDB_ERR_GTMSECSHRBADDIR* = -150382796 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1320:9
else:
  let YDB_ERR_GTMSECSHRBADDIR* = -150382796 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1320:9
when -150382800 is static:
  const
    YDB_ERR_JNLBUFFREGUPD* = -150382800 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1321:9
else:
  let YDB_ERR_JNLBUFFREGUPD* = -150382800 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1321:9
when -150382808 is static:
  const
    YDB_ERR_JNLBUFFDBUPD* = -150382808 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1322:9
else:
  let YDB_ERR_JNLBUFFDBUPD* = -150382808 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1322:9
when -150382818 is static:
  const
    YDB_ERR_LOCKINCR2HIGH* = -150382818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1323:9
else:
  let YDB_ERR_LOCKINCR2HIGH* = -150382818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1323:9
when -150382827 is static:
  const
    YDB_ERR_LOCKIS* = -150382827 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1324:9
else:
  let YDB_ERR_LOCKIS* = -150382827 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1324:9
when -150382834 is static:
  const
    YDB_ERR_LDSPANGLOINCMP* = -150382834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1325:9
else:
  let YDB_ERR_LDSPANGLOINCMP* = -150382834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1325:9
when -150382842 is static:
  const
    YDB_ERR_MUFILRNDWNFL2* = -150382842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1326:9
else:
  let YDB_ERR_MUFILRNDWNFL2* = -150382842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1326:9
when -150382851 is static:
  const
    YDB_ERR_MUINSTFROZEN* = -150382851 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1327:9
else:
  let YDB_ERR_MUINSTFROZEN* = -150382851 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1327:9
when -150382859 is static:
  const
    YDB_ERR_MUINSTUNFROZEN* = -150382859 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1328:9
else:
  let YDB_ERR_MUINSTUNFROZEN* = -150382859 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1328:9
when -150382866 is static:
  const
    YDB_ERR_GTMEISDIR* = -150382866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1329:9
else:
  let YDB_ERR_GTMEISDIR* = -150382866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1329:9
when -150382874 is static:
  const
    YDB_ERR_SPCLZMSG* = -150382874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1330:9
else:
  let YDB_ERR_SPCLZMSG* = -150382874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1330:9
when -150382880 is static:
  const
    YDB_ERR_MUNOTALLINTEG* = -150382880 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1331:9
else:
  let YDB_ERR_MUNOTALLINTEG* = -150382880 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1331:9
when -150382890 is static:
  const
    YDB_ERR_BKUPRUNNING* = -150382890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1332:9
else:
  let YDB_ERR_BKUPRUNNING* = -150382890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1332:9
when -150382898 is static:
  const
    YDB_ERR_MUSIZEINVARG* = -150382898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1333:9
else:
  let YDB_ERR_MUSIZEINVARG* = -150382898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1333:9
when -150382906 is static:
  const
    YDB_ERR_MUSIZEFAIL* = -150382906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1334:9
else:
  let YDB_ERR_MUSIZEFAIL* = -150382906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1334:9
when -150382912 is static:
  const
    YDB_ERR_SIDEEFFECTEVAL* = -150382912 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1335:9
else:
  let YDB_ERR_SIDEEFFECTEVAL* = -150382912 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1335:9
when -150382922 is static:
  const
    YDB_ERR_CRYPTINIT2* = -150382922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1336:9
else:
  let YDB_ERR_CRYPTINIT2* = -150382922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1336:9
when -150382930 is static:
  const
    YDB_ERR_CRYPTDLNOOPEN2* = -150382930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1337:9
else:
  let YDB_ERR_CRYPTDLNOOPEN2* = -150382930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1337:9
when -418818394 is static:
  const
    YDB_ERR_CRYPTBADCONFIG* = -418818394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1338:9
else:
  let YDB_ERR_CRYPTBADCONFIG* = -418818394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1338:9
when -150382944 is static:
  const
    YDB_ERR_DBCOLLREQ* = -150382944 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1339:9
else:
  let YDB_ERR_DBCOLLREQ* = -150382944 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1339:9
when -150382954 is static:
  const
    YDB_ERR_SETEXTRENV* = -150382954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1340:9
else:
  let YDB_ERR_SETEXTRENV* = -150382954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1340:9
when -150382962 is static:
  const
    YDB_ERR_NOTALLDBRNDWN* = -150382962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1341:9
else:
  let YDB_ERR_NOTALLDBRNDWN* = -150382962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1341:9
when -150382970 is static:
  const
    YDB_ERR_TPRESTNESTERR* = -150382970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1342:9
else:
  let YDB_ERR_TPRESTNESTERR* = -150382970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1342:9
when -150382978 is static:
  const
    YDB_ERR_JNLFILRDOPN* = -150382978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1343:9
else:
  let YDB_ERR_JNLFILRDOPN* = -150382978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1343:9
when -150382986 is static:
  const
    YDB_ERR_UNUSEDMSG1514* = -150382986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1344:9
else:
  let YDB_ERR_UNUSEDMSG1514* = -150382986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1344:9
when -150382995 is static:
  const
    YDB_ERR_FTOKKEY* = -150382995 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1345:9
else:
  let YDB_ERR_FTOKKEY* = -150382995 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1345:9
when -150383003 is static:
  const
    YDB_ERR_SEMID* = -150383003 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1346:9
else:
  let YDB_ERR_SEMID* = -150383003 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1346:9
when -150383011 is static:
  const
    YDB_ERR_JNLQIOSALVAGE* = -150383011 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1347:9
else:
  let YDB_ERR_JNLQIOSALVAGE* = -150383011 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1347:9
when -150383019 is static:
  const
    YDB_ERR_FAKENOSPCLEARED* = -150383019 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1348:9
else:
  let YDB_ERR_FAKENOSPCLEARED* = -150383019 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1348:9
when -150383026 is static:
  const
    YDB_ERR_MMFILETOOLARGE* = -150383026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1349:9
else:
  let YDB_ERR_MMFILETOOLARGE* = -150383026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1349:9
when -150383034 is static:
  const
    YDB_ERR_BADZPEEKARG* = -150383034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1350:9
else:
  let YDB_ERR_BADZPEEKARG* = -150383034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1350:9
when -150383042 is static:
  const
    YDB_ERR_BADZPEEKRANGE* = -150383042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1351:9
else:
  let YDB_ERR_BADZPEEKRANGE* = -150383042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1351:9
when -150383050 is static:
  const
    YDB_ERR_BADZPEEKFMT* = -150383050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1352:9
else:
  let YDB_ERR_BADZPEEKFMT* = -150383050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1352:9
when -150383056 is static:
  const
    YDB_ERR_DBMBMINCFREFIXED* = -150383056 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1353:9
else:
  let YDB_ERR_DBMBMINCFREFIXED* = -150383056 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1353:9
when -150383066 is static:
  const
    YDB_ERR_NULLENTRYREF* = -150383066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1354:9
else:
  let YDB_ERR_NULLENTRYREF* = -150383066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1354:9
when -150383074 is static:
  const
    YDB_ERR_ZPEEKNORPLINFO* = -150383074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1355:9
else:
  let YDB_ERR_ZPEEKNORPLINFO* = -150383074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1355:9
when -150383082 is static:
  const
    YDB_ERR_MMREGNOACCESS* = -150383082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1356:9
else:
  let YDB_ERR_MMREGNOACCESS* = -150383082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1356:9
when -150383090 is static:
  const
    YDB_ERR_UNUSEDMSG1527* = -150383090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1357:9
else:
  let YDB_ERR_UNUSEDMSG1527* = -150383090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1357:9
when -150383096 is static:
  const
    YDB_ERR_MALLOCCRIT* = -150383096 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1358:9
else:
  let YDB_ERR_MALLOCCRIT* = -150383096 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1358:9
when -150383106 is static:
  const
    YDB_ERR_HOSTCONFLICT* = -150383106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1359:9
else:
  let YDB_ERR_HOSTCONFLICT* = -150383106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1359:9
when -150383114 is static:
  const
    YDB_ERR_GETADDRINFO* = -150383114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1360:9
else:
  let YDB_ERR_GETADDRINFO* = -150383114 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1360:9
when -150383122 is static:
  const
    YDB_ERR_GETNAMEINFO* = -150383122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1361:9
else:
  let YDB_ERR_GETNAMEINFO* = -150383122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1361:9
when -150383130 is static:
  const
    YDB_ERR_SOCKBIND* = -150383130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1362:9
else:
  let YDB_ERR_SOCKBIND* = -150383130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1362:9
when -150383139 is static:
  const
    YDB_ERR_INSTFRZDEFER* = -150383139 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1363:9
else:
  let YDB_ERR_INSTFRZDEFER* = -150383139 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1363:9
when -150383146 is static:
  const
    YDB_ERR_VIEWARGTOOLONG* = -150383146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1364:9
else:
  let YDB_ERR_VIEWARGTOOLONG* = -150383146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1364:9
when -150383154 is static:
  const
    YDB_ERR_REGOPENFAIL* = -150383154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1365:9
else:
  let YDB_ERR_REGOPENFAIL* = -150383154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1365:9
when -150383162 is static:
  const
    YDB_ERR_REPLINSTNOSHM* = -150383162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1366:9
else:
  let YDB_ERR_REPLINSTNOSHM* = -150383162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1366:9
when -150383170 is static:
  const
    YDB_ERR_DEVPARMTOOSMALL* = -150383170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1367:9
else:
  let YDB_ERR_DEVPARMTOOSMALL* = -150383170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1367:9
when -150383178 is static:
  const
    YDB_ERR_REMOTEDBNOSPGBL* = -150383178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1368:9
else:
  let YDB_ERR_REMOTEDBNOSPGBL* = -150383178 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1368:9
when -150383186 is static:
  const
    YDB_ERR_NCTCOLLSPGBL* = -150383186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1369:9
else:
  let YDB_ERR_NCTCOLLSPGBL* = -150383186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1369:9
when -150383194 is static:
  const
    YDB_ERR_ACTCOLLMISMTCH* = -150383194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1370:9
else:
  let YDB_ERR_ACTCOLLMISMTCH* = -150383194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1370:9
when -150383202 is static:
  const
    YDB_ERR_GBLNOMAPTOREG* = -150383202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1371:9
else:
  let YDB_ERR_GBLNOMAPTOREG* = -150383202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1371:9
when -150383210 is static:
  const
    YDB_ERR_ISSPANGBL* = -150383210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1372:9
else:
  let YDB_ERR_ISSPANGBL* = -150383210 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1372:9
when -150383218 is static:
  const
    YDB_ERR_TPNOSUPPORT* = -150383218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1373:9
else:
  let YDB_ERR_TPNOSUPPORT* = -150383218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1373:9
when -150383226 is static:
  const
    YDB_ERR_EXITSTATUS* = -150383226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1374:9
else:
  let YDB_ERR_EXITSTATUS* = -150383226 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1374:9
when -150383234 is static:
  const
    YDB_ERR_ZATRANSERR* = -150383234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1375:9
else:
  let YDB_ERR_ZATRANSERR* = -150383234 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1375:9
when -150383242 is static:
  const
    YDB_ERR_FILTERTIMEDOUT* = -150383242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1376:9
else:
  let YDB_ERR_FILTERTIMEDOUT* = -150383242 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1376:9
when -150383250 is static:
  const
    YDB_ERR_TLSDLLNOOPEN* = -150383250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1377:9
else:
  let YDB_ERR_TLSDLLNOOPEN* = -150383250 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1377:9
when -150383258 is static:
  const
    YDB_ERR_TLSINIT* = -150383258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1378:9
else:
  let YDB_ERR_TLSINIT* = -150383258 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1378:9
when -150383266 is static:
  const
    YDB_ERR_TLSCONVSOCK* = -150383266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1379:9
else:
  let YDB_ERR_TLSCONVSOCK* = -150383266 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1379:9
when -150383274 is static:
  const
    YDB_ERR_TLSHANDSHAKE* = -150383274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1380:9
else:
  let YDB_ERR_TLSHANDSHAKE* = -150383274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1380:9
when -150383280 is static:
  const
    YDB_ERR_TLSCONNINFO* = -150383280 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1381:9
else:
  let YDB_ERR_TLSCONNINFO* = -150383280 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1381:9
when -150383290 is static:
  const
    YDB_ERR_TLSIOERROR* = -150383290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1382:9
else:
  let YDB_ERR_TLSIOERROR* = -150383290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1382:9
when -150383298 is static:
  const
    YDB_ERR_TLSRENEGOTIATE* = -150383298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1383:9
else:
  let YDB_ERR_TLSRENEGOTIATE* = -150383298 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1383:9
when -150383306 is static:
  const
    YDB_ERR_REPLNOTLS* = -150383306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1384:9
else:
  let YDB_ERR_REPLNOTLS* = -150383306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1384:9
when -150383314 is static:
  const
    YDB_ERR_COLTRANSSTR2LONG* = -150383314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1385:9
else:
  let YDB_ERR_COLTRANSSTR2LONG* = -150383314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1385:9
when -150383322 is static:
  const
    YDB_ERR_SOCKPASS* = -150383322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1386:9
else:
  let YDB_ERR_SOCKPASS* = -150383322 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1386:9
when -150383330 is static:
  const
    YDB_ERR_SOCKACCEPT* = -150383330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1387:9
else:
  let YDB_ERR_SOCKACCEPT* = -150383330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1387:9
when -150383338 is static:
  const
    YDB_ERR_NOSOCKHANDLE* = -150383338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1388:9
else:
  let YDB_ERR_NOSOCKHANDLE* = -150383338 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1388:9
when -150383346 is static:
  const
    YDB_ERR_TRIGLOADFAIL* = -150383346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1389:9
else:
  let YDB_ERR_TRIGLOADFAIL* = -150383346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1389:9
when -150383354 is static:
  const
    YDB_ERR_SOCKPASSDATAMIX* = -150383354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1390:9
else:
  let YDB_ERR_SOCKPASSDATAMIX* = -150383354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1390:9
when -150383362 is static:
  const
    YDB_ERR_NOGTCMDB* = -150383362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1391:9
else:
  let YDB_ERR_NOGTCMDB* = -150383362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1391:9
when -150383370 is static:
  const
    YDB_ERR_NOUSERDB* = -150383370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1392:9
else:
  let YDB_ERR_NOUSERDB* = -150383370 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1392:9
when -150383378 is static:
  const
    YDB_ERR_DSENOTOPEN* = -150383378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1393:9
else:
  let YDB_ERR_DSENOTOPEN* = -150383378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1393:9
when -150383386 is static:
  const
    YDB_ERR_ZSOCKETATTR* = -150383386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1394:9
else:
  let YDB_ERR_ZSOCKETATTR* = -150383386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1394:9
when -150383394 is static:
  const
    YDB_ERR_ZSOCKETNOTSOCK* = -150383394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1395:9
else:
  let YDB_ERR_ZSOCKETNOTSOCK* = -150383394 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1395:9
when -150383402 is static:
  const
    YDB_ERR_CHSETALREADY* = -150383402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1396:9
else:
  let YDB_ERR_CHSETALREADY* = -150383402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1396:9
when -150383410 is static:
  const
    YDB_ERR_DSEMAXBLKSAV* = -150383410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1397:9
else:
  let YDB_ERR_DSEMAXBLKSAV* = -150383410 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1397:9
when -150383418 is static:
  const
    YDB_ERR_BLKINVALID* = -150383418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1398:9
else:
  let YDB_ERR_BLKINVALID* = -150383418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1398:9
when -150383426 is static:
  const
    YDB_ERR_CANTBITMAP* = -150383426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1399:9
else:
  let YDB_ERR_CANTBITMAP* = -150383426 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1399:9
when -150383434 is static:
  const
    YDB_ERR_AIMGBLKFAIL* = -150383434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1400:9
else:
  let YDB_ERR_AIMGBLKFAIL* = -150383434 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1400:9
when -150383442 is static:
  const
    YDB_ERR_YDBDISTUNVERIF* = -150383442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1401:9
else:
  let YDB_ERR_YDBDISTUNVERIF* = -150383442 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1401:9
when -150383450 is static:
  const
    YDB_ERR_CRYPTNOAPPEND* = -150383450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1402:9
else:
  let YDB_ERR_CRYPTNOAPPEND* = -150383450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1402:9
when -150383458 is static:
  const
    YDB_ERR_CRYPTNOSEEK* = -150383458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1403:9
else:
  let YDB_ERR_CRYPTNOSEEK* = -150383458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1403:9
when -150383466 is static:
  const
    YDB_ERR_CRYPTNOTRUNC* = -150383466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1404:9
else:
  let YDB_ERR_CRYPTNOTRUNC* = -150383466 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1404:9
when -150383474 is static:
  const
    YDB_ERR_CRYPTNOKEYSPEC* = -150383474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1405:9
else:
  let YDB_ERR_CRYPTNOKEYSPEC* = -150383474 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1405:9
when -150383482 is static:
  const
    YDB_ERR_CRYPTNOOVERRIDE* = -150383482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1406:9
else:
  let YDB_ERR_CRYPTNOOVERRIDE* = -150383482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1406:9
when -150383490 is static:
  const
    YDB_ERR_CRYPTKEYTOOBIG* = -150383490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1407:9
else:
  let YDB_ERR_CRYPTKEYTOOBIG* = -150383490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1407:9
when -150383498 is static:
  const
    YDB_ERR_CRYPTBADWRTPOS* = -150383498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1408:9
else:
  let YDB_ERR_CRYPTBADWRTPOS* = -150383498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1408:9
when -150383506 is static:
  const
    YDB_ERR_LABELNOTFND* = -150383506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1409:9
else:
  let YDB_ERR_LABELNOTFND* = -150383506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1409:9
when -150383514 is static:
  const
    YDB_ERR_RELINKCTLERR* = -150383514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1410:9
else:
  let YDB_ERR_RELINKCTLERR* = -150383514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1410:9
when -150383522 is static:
  const
    YDB_ERR_INVLINKTMPDIR* = -150383522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1411:9
else:
  let YDB_ERR_INVLINKTMPDIR* = -150383522 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1411:9
when -150383530 is static:
  const
    YDB_ERR_NOEDITOR* = -150383530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1412:9
else:
  let YDB_ERR_NOEDITOR* = -150383530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1412:9
when -150383538 is static:
  const
    YDB_ERR_UPDPROC* = -150383538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1413:9
else:
  let YDB_ERR_UPDPROC* = -150383538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1413:9
when -150383546 is static:
  const
    YDB_ERR_HLPPROC* = -150383546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1414:9
else:
  let YDB_ERR_HLPPROC* = -150383546 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1414:9
when -150383554 is static:
  const
    YDB_ERR_REPLNOHASHTREC* = -150383554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1415:9
else:
  let YDB_ERR_REPLNOHASHTREC* = -150383554 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1415:9
when -150383562 is static:
  const
    YDB_ERR_REMOTEDBNOTRIG* = -150383562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1416:9
else:
  let YDB_ERR_REMOTEDBNOTRIG* = -150383562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1416:9
when -150383570 is static:
  const
    YDB_ERR_NEEDTRIGUPGRD* = -150383570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1417:9
else:
  let YDB_ERR_NEEDTRIGUPGRD* = -150383570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1417:9
when -150383578 is static:
  const
    YDB_ERR_REQRLNKCTLRNDWN* = -150383578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1418:9
else:
  let YDB_ERR_REQRLNKCTLRNDWN* = -150383578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1418:9
when -150383587 is static:
  const
    YDB_ERR_RLNKCTLRNDWNSUC* = -150383587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1419:9
else:
  let YDB_ERR_RLNKCTLRNDWNSUC* = -150383587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1419:9
when -150383594 is static:
  const
    YDB_ERR_RLNKCTLRNDWNFL* = -150383594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1420:9
else:
  let YDB_ERR_RLNKCTLRNDWNFL* = -150383594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1420:9
when -150383602 is static:
  const
    YDB_ERR_MPROFRUNDOWN* = -150383602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1421:9
else:
  let YDB_ERR_MPROFRUNDOWN* = -150383602 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1421:9
when -150383610 is static:
  const
    YDB_ERR_ZPEEKNOJNLINFO* = -150383610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1422:9
else:
  let YDB_ERR_ZPEEKNOJNLINFO* = -150383610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1422:9
when -150383618 is static:
  const
    YDB_ERR_TLSPARAM* = -150383618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1423:9
else:
  let YDB_ERR_TLSPARAM* = -150383618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1423:9
when -150383626 is static:
  const
    YDB_ERR_RLNKRECLATCH* = -150383626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1424:9
else:
  let YDB_ERR_RLNKRECLATCH* = -150383626 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1424:9
when -150383634 is static:
  const
    YDB_ERR_RLNKSHMLATCH* = -150383634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1425:9
else:
  let YDB_ERR_RLNKSHMLATCH* = -150383634 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1425:9
when -150383642 is static:
  const
    YDB_ERR_JOBLVN2LONG* = -150383642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1426:9
else:
  let YDB_ERR_JOBLVN2LONG* = -150383642 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1426:9
when -150383648 is static:
  const
    YDB_ERR_NLRESTORE* = -150383648 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1427:9
else:
  let YDB_ERR_NLRESTORE* = -150383648 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1427:9
when -150383658 is static:
  const
    YDB_ERR_PREALLOCATEFAIL* = -150383658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1428:9
else:
  let YDB_ERR_PREALLOCATEFAIL* = -150383658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1428:9
when -150383664 is static:
  const
    YDB_ERR_NODFRALLOCSUPP* = -150383664 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1429:9
else:
  let YDB_ERR_NODFRALLOCSUPP* = -150383664 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1429:9
when -150383672 is static:
  const
    YDB_ERR_LASTWRITERBYPAS* = -150383672 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1430:9
else:
  let YDB_ERR_LASTWRITERBYPAS* = -150383672 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1430:9
when -150383682 is static:
  const
    YDB_ERR_TRIGUPBADLABEL* = -150383682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1431:9
else:
  let YDB_ERR_TRIGUPBADLABEL* = -150383682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1431:9
when -150383690 is static:
  const
    YDB_ERR_WEIRDSYSTIME* = -150383690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1432:9
else:
  let YDB_ERR_WEIRDSYSTIME* = -150383690 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1432:9
when -150383696 is static:
  const
    YDB_ERR_REPLSRCEXITERR* = -150383696 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1433:9
else:
  let YDB_ERR_REPLSRCEXITERR* = -150383696 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1433:9
when -150383706 is static:
  const
    YDB_ERR_INVZBREAK* = -150383706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1434:9
else:
  let YDB_ERR_INVZBREAK* = -150383706 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1434:9
when -150383714 is static:
  const
    YDB_ERR_INVTMPDIR* = -150383714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1435:9
else:
  let YDB_ERR_INVTMPDIR* = -150383714 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1435:9
when -150383720 is static:
  const
    YDB_ERR_ARCTLMAXHIGH* = -150383720 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1436:9
else:
  let YDB_ERR_ARCTLMAXHIGH* = -150383720 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1436:9
when -150383728 is static:
  const
    YDB_ERR_ARCTLMAXLOW* = -150383728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1437:9
else:
  let YDB_ERR_ARCTLMAXLOW* = -150383728 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1437:9
when -150383739 is static:
  const
    YDB_ERR_NONTPRESTART* = -150383739 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1438:9
else:
  let YDB_ERR_NONTPRESTART* = -150383739 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1438:9
when -150383746 is static:
  const
    YDB_ERR_PBNPARMREQ* = -150383746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1439:9
else:
  let YDB_ERR_PBNPARMREQ* = -150383746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1439:9
when -150383754 is static:
  const
    YDB_ERR_PBNNOPARM* = -150383754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1440:9
else:
  let YDB_ERR_PBNNOPARM* = -150383754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1440:9
when -150383762 is static:
  const
    YDB_ERR_PBNUNSUPSTRUCT* = -150383762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1441:9
else:
  let YDB_ERR_PBNUNSUPSTRUCT* = -150383762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1441:9
when -150383770 is static:
  const
    YDB_ERR_PBNINVALID* = -150383770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1442:9
else:
  let YDB_ERR_PBNINVALID* = -150383770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1442:9
when -150383778 is static:
  const
    YDB_ERR_PBNNOFIELD* = -150383778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1443:9
else:
  let YDB_ERR_PBNNOFIELD* = -150383778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1443:9
when -150383786 is static:
  const
    YDB_ERR_JNLDBSEQNOMATCH* = -150383786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1444:9
else:
  let YDB_ERR_JNLDBSEQNOMATCH* = -150383786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1444:9
when -150383794 is static:
  const
    YDB_ERR_MULTIPROCLATCH* = -150383794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1445:9
else:
  let YDB_ERR_MULTIPROCLATCH* = -150383794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1445:9
when -150383802 is static:
  const
    YDB_ERR_INVLOCALE* = -150383802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1446:9
else:
  let YDB_ERR_INVLOCALE* = -150383802 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1446:9
when -150383811 is static:
  const
    YDB_ERR_NOMORESEMCNT* = -150383811 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1447:9
else:
  let YDB_ERR_NOMORESEMCNT* = -150383811 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1447:9
when -150383818 is static:
  const
    YDB_ERR_SETQUALPROB* = -150383818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1448:9
else:
  let YDB_ERR_SETQUALPROB* = -150383818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1448:9
when -150383826 is static:
  const
    YDB_ERR_EXTRINTEGRITY* = -150383826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1449:9
else:
  let YDB_ERR_EXTRINTEGRITY* = -150383826 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1449:9
when -418819290 is static:
  const
    YDB_ERR_CRYPTKEYRELEASEFAILED* = -418819290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1450:9
else:
  let YDB_ERR_CRYPTKEYRELEASEFAILED* = -418819290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1450:9
when -150383843 is static:
  const
    YDB_ERR_MUREENCRYPTSTART* = -150383843 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1451:9
else:
  let YDB_ERR_MUREENCRYPTSTART* = -150383843 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1451:9
when -150383850 is static:
  const
    YDB_ERR_MUREENCRYPTV4NOALLOW* = -150383850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1452:9
else:
  let YDB_ERR_MUREENCRYPTV4NOALLOW* = -150383850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1452:9
when -150383858 is static:
  const
    YDB_ERR_ENCRYPTCONFLT* = -150383858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1453:9
else:
  let YDB_ERR_ENCRYPTCONFLT* = -150383858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1453:9
when -150383866 is static:
  const
    YDB_ERR_JNLPOOLRECOVERY* = -150383866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1454:9
else:
  let YDB_ERR_JNLPOOLRECOVERY* = -150383866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1454:9
when -150383872 is static:
  const
    YDB_ERR_LOCKTIMINGINTP* = -150383872 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1455:9
else:
  let YDB_ERR_LOCKTIMINGINTP* = -150383872 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1455:9
when -150383882 is static:
  const
    YDB_ERR_PBNUNSUPTYPE* = -150383882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1456:9
else:
  let YDB_ERR_PBNUNSUPTYPE* = -150383882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1456:9
when -150383891 is static:
  const
    YDB_ERR_DBFHEADLRU* = -150383891 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1457:9
else:
  let YDB_ERR_DBFHEADLRU* = -150383891 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1457:9
when -150383898 is static:
  const
    YDB_ERR_ASYNCIONOV4* = -150383898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1458:9
else:
  let YDB_ERR_ASYNCIONOV4* = -150383898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1458:9
when -150383906 is static:
  const
    YDB_ERR_AIOCANCELTIMEOUT* = -150383906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1459:9
else:
  let YDB_ERR_AIOCANCELTIMEOUT* = -150383906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1459:9
when -150383914 is static:
  const
    YDB_ERR_DBGLDMISMATCH* = -150383914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1460:9
else:
  let YDB_ERR_DBGLDMISMATCH* = -150383914 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1460:9
when -150383922 is static:
  const
    YDB_ERR_DBBLKSIZEALIGN* = -150383922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1461:9
else:
  let YDB_ERR_DBBLKSIZEALIGN* = -150383922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1461:9
when -150383930 is static:
  const
    YDB_ERR_ASYNCIONOMM* = -150383930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1462:9
else:
  let YDB_ERR_ASYNCIONOMM* = -150383930 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1462:9
when -150383938 is static:
  const
    YDB_ERR_RESYNCSEQLOW* = -150383938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1463:9
else:
  let YDB_ERR_RESYNCSEQLOW* = -150383938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1463:9
when -150383946 is static:
  const
    YDB_ERR_DBNULCOL* = -150383946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1464:9
else:
  let YDB_ERR_DBNULCOL* = -150383946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1464:9
when -150383954 is static:
  const
    YDB_ERR_UTF16ENDIAN* = -150383954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1465:9
else:
  let YDB_ERR_UTF16ENDIAN* = -150383954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1465:9
when -150383960 is static:
  const
    YDB_ERR_OFRZACTIVE* = -150383960 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1466:9
else:
  let YDB_ERR_OFRZACTIVE* = -150383960 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1466:9
when -150383968 is static:
  const
    YDB_ERR_OFRZAUTOREL* = -150383968 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1467:9
else:
  let YDB_ERR_OFRZAUTOREL* = -150383968 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1467:9
when -150383976 is static:
  const
    YDB_ERR_OFRZCRITREL* = -150383976 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1468:9
else:
  let YDB_ERR_OFRZCRITREL* = -150383976 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1468:9
when -150383984 is static:
  const
    YDB_ERR_OFRZCRITSTUCK* = -150383984 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1469:9
else:
  let YDB_ERR_OFRZCRITSTUCK* = -150383984 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1469:9
when -150383992 is static:
  const
    YDB_ERR_OFRZNOTHELD* = -150383992 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1470:9
else:
  let YDB_ERR_OFRZNOTHELD* = -150383992 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1470:9
when -150384002 is static:
  const
    YDB_ERR_AIOBUFSTUCK* = -150384002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1471:9
else:
  let YDB_ERR_AIOBUFSTUCK* = -150384002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1471:9
when -150384010 is static:
  const
    YDB_ERR_DBDUPNULCOL* = -150384010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1472:9
else:
  let YDB_ERR_DBDUPNULCOL* = -150384010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1472:9
when -150384019 is static:
  const
    YDB_ERR_CHANGELOGINTERVAL* = -150384019 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1473:9
else:
  let YDB_ERR_CHANGELOGINTERVAL* = -150384019 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1473:9
when -150384026 is static:
  const
    YDB_ERR_DBNONUMSUBS* = -150384026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1474:9
else:
  let YDB_ERR_DBNONUMSUBS* = -150384026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1474:9
when -150384034 is static:
  const
    YDB_ERR_AUTODBCREFAIL* = -150384034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1475:9
else:
  let YDB_ERR_AUTODBCREFAIL* = -150384034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1475:9
when -150384042 is static:
  const
    YDB_ERR_RNDWNSTATSDBFAIL* = -150384042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1476:9
else:
  let YDB_ERR_RNDWNSTATSDBFAIL* = -150384042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1476:9
when -150384050 is static:
  const
    YDB_ERR_STATSDBNOTSUPP* = -150384050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1477:9
else:
  let YDB_ERR_STATSDBNOTSUPP* = -150384050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1477:9
when -150384058 is static:
  const
    YDB_ERR_TPNOSTATSHARE* = -150384058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1478:9
else:
  let YDB_ERR_TPNOSTATSHARE* = -150384058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1478:9
when -150384066 is static:
  const
    YDB_ERR_FNTRANSERROR* = -150384066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1479:9
else:
  let YDB_ERR_FNTRANSERROR* = -150384066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1479:9
when -150384074 is static:
  const
    YDB_ERR_NOCRENETFILE* = -150384074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1480:9
else:
  let YDB_ERR_NOCRENETFILE* = -150384074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1480:9
when -150384082 is static:
  const
    YDB_ERR_DSKSPCCHK* = -150384082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1481:9
else:
  let YDB_ERR_DSKSPCCHK* = -150384082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1481:9
when -150384090 is static:
  const
    YDB_ERR_NOCREMMBIJ* = -150384090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1482:9
else:
  let YDB_ERR_NOCREMMBIJ* = -150384090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1482:9
when -150384098 is static:
  const
    YDB_ERR_FILECREERR* = -150384098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1483:9
else:
  let YDB_ERR_FILECREERR* = -150384098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1483:9
when -150384106 is static:
  const
    YDB_ERR_RAWDEVUNSUP* = -150384106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1484:9
else:
  let YDB_ERR_RAWDEVUNSUP* = -150384106 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1484:9
when -150384115 is static:
  const
    YDB_ERR_DBFILECREATED* = -150384115 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1485:9
else:
  let YDB_ERR_DBFILECREATED* = -150384115 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1485:9
when -150384122 is static:
  const
    YDB_ERR_PCTYRESERVED* = -150384122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1486:9
else:
  let YDB_ERR_PCTYRESERVED* = -150384122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1486:9
when -418819587 is static:
  const
    YDB_ERR_REGFILENOTFOUND* = -418819587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1487:9
else:
  let YDB_ERR_REGFILENOTFOUND* = -418819587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1487:9
when -150384138 is static:
  const
    YDB_ERR_DRVLONGJMP* = -150384138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1488:9
else:
  let YDB_ERR_DRVLONGJMP* = -150384138 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1488:9
when -150384146 is static:
  const
    YDB_ERR_INVSTATSDB* = -150384146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1489:9
else:
  let YDB_ERR_INVSTATSDB* = -150384146 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1489:9
when -150384154 is static:
  const
    YDB_ERR_STATSDBERR* = -150384154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1490:9
else:
  let YDB_ERR_STATSDBERR* = -150384154 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1490:9
when -150384162 is static:
  const
    YDB_ERR_STATSDBINUSE* = -150384162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1491:9
else:
  let YDB_ERR_STATSDBINUSE* = -150384162 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1491:9
when -150384170 is static:
  const
    YDB_ERR_STATSDBFNERR* = -150384170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1492:9
else:
  let YDB_ERR_STATSDBFNERR* = -150384170 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1492:9
when -150384179 is static:
  const
    YDB_ERR_JNLSWITCHRETRY* = -150384179 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1493:9
else:
  let YDB_ERR_JNLSWITCHRETRY* = -150384179 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1493:9
when -150384186 is static:
  const
    YDB_ERR_JNLSWITCHFAIL* = -150384186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1494:9
else:
  let YDB_ERR_JNLSWITCHFAIL* = -150384186 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1494:9
when -150384194 is static:
  const
    YDB_ERR_CLISTRTOOLONG* = -150384194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1495:9
else:
  let YDB_ERR_CLISTRTOOLONG* = -150384194 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1495:9
when -150384202 is static:
  const
    YDB_ERR_LVMONBADVAL* = -150384202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1496:9
else:
  let YDB_ERR_LVMONBADVAL* = -150384202 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1496:9
when -418819666 is static:
  const
    YDB_ERR_RESTRICTEDOP* = -418819666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1497:9
else:
  let YDB_ERR_RESTRICTEDOP* = -418819666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1497:9
when -150384218 is static:
  const
    YDB_ERR_RESTRICTSYNTAX* = -150384218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1498:9
else:
  let YDB_ERR_RESTRICTSYNTAX* = -150384218 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1498:9
when -418819682 is static:
  const
    YDB_ERR_MUCREFILERR* = -418819682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1499:9
else:
  let YDB_ERR_MUCREFILERR* = -418819682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1499:9
when -150384235 is static:
  const
    YDB_ERR_JNLBUFFPHS2SALVAGE* = -150384235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1500:9
else:
  let YDB_ERR_JNLBUFFPHS2SALVAGE* = -150384235 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1500:9
when -150384243 is static:
  const
    YDB_ERR_JNLPOOLPHS2SALVAGE* = -150384243 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1501:9
else:
  let YDB_ERR_JNLPOOLPHS2SALVAGE* = -150384243 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1501:9
when -150384251 is static:
  const
    YDB_ERR_MURNDWNARGLESS* = -150384251 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1502:9
else:
  let YDB_ERR_MURNDWNARGLESS* = -150384251 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1502:9
when -150384259 is static:
  const
    YDB_ERR_DBFREEZEON* = -150384259 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1503:9
else:
  let YDB_ERR_DBFREEZEON* = -150384259 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1503:9
when -150384267 is static:
  const
    YDB_ERR_DBFREEZEOFF* = -150384267 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1504:9
else:
  let YDB_ERR_DBFREEZEOFF* = -150384267 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1504:9
when -150384274 is static:
  const
    YDB_ERR_STPCRIT* = -150384274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1505:9
else:
  let YDB_ERR_STPCRIT* = -150384274 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1505:9
when -150384284 is static:
  const
    YDB_ERR_STPOFLOW* = -150384284 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1506:9
else:
  let YDB_ERR_STPOFLOW* = -150384284 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1506:9
when -150384290 is static:
  const
    YDB_ERR_SYSUTILCONF* = -150384290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1507:9
else:
  let YDB_ERR_SYSUTILCONF* = -150384290 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1507:9
when -150384299 is static:
  const
    YDB_ERR_MSTACKSZNA* = -150384299 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1508:9
else:
  let YDB_ERR_MSTACKSZNA* = -150384299 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1508:9
when -150384306 is static:
  const
    YDB_ERR_JNLEXTRCTSEQNO* = -150384306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1509:9
else:
  let YDB_ERR_JNLEXTRCTSEQNO* = -150384306 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1509:9
when -150384314 is static:
  const
    YDB_ERR_INVSEQNOQUAL* = -150384314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1510:9
else:
  let YDB_ERR_INVSEQNOQUAL* = -150384314 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1510:9
when -150384323 is static:
  const
    YDB_ERR_LOWSPC* = -150384323 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1511:9
else:
  let YDB_ERR_LOWSPC* = -150384323 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1511:9
when -150384330 is static:
  const
    YDB_ERR_FAILEDRECCOUNT* = -150384330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1512:9
else:
  let YDB_ERR_FAILEDRECCOUNT* = -150384330 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1512:9
when -150384339 is static:
  const
    YDB_ERR_LOADRECCNT* = -150384339 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1513:9
else:
  let YDB_ERR_LOADRECCNT* = -150384339 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1513:9
when -150384346 is static:
  const
    YDB_ERR_COMMFILTERERR* = -150384346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1514:9
else:
  let YDB_ERR_COMMFILTERERR* = -150384346 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1514:9
when -150384354 is static:
  const
    YDB_ERR_NOFILTERNEST* = -150384354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1515:9
else:
  let YDB_ERR_NOFILTERNEST* = -150384354 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1515:9
when -150384362 is static:
  const
    YDB_ERR_MLKHASHTABERR* = -150384362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1516:9
else:
  let YDB_ERR_MLKHASHTABERR* = -150384362 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1516:9
when -150384371 is static:
  const
    YDB_ERR_LOCKCRITOWNER* = -150384371 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1517:9
else:
  let YDB_ERR_LOCKCRITOWNER* = -150384371 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1517:9
when -150384378 is static:
  const
    YDB_ERR_MLKHASHWRONG* = -150384378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1518:9
else:
  let YDB_ERR_MLKHASHWRONG* = -150384378 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1518:9
when -150384386 is static:
  const
    YDB_ERR_XCRETNULLREF* = -150384386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1519:9
else:
  let YDB_ERR_XCRETNULLREF* = -150384386 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1519:9
when -150384396 is static:
  const
    YDB_ERR_EXTCALLBOUNDS* = -150384396 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1520:9
else:
  let YDB_ERR_EXTCALLBOUNDS* = -150384396 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1520:9
when -150384402 is static:
  const
    YDB_ERR_EXCEEDSPREALLOC* = -150384402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1521:9
else:
  let YDB_ERR_EXCEEDSPREALLOC* = -150384402 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1521:9
when -150384408 is static:
  const
    YDB_ERR_ZTIMEOUT* = -150384408 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1522:9
else:
  let YDB_ERR_ZTIMEOUT* = -150384408 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1522:9
when -150384418 is static:
  const
    YDB_ERR_ERRWZTIMEOUT* = -150384418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1523:9
else:
  let YDB_ERR_ERRWZTIMEOUT* = -150384418 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1523:9
when -150384427 is static:
  const
    YDB_ERR_MLKHASHRESIZE* = -150384427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1524:9
else:
  let YDB_ERR_MLKHASHRESIZE* = -150384427 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1524:9
when -150384432 is static:
  const
    YDB_ERR_MLKHASHRESIZEFAIL* = -150384432 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1525:9
else:
  let YDB_ERR_MLKHASHRESIZEFAIL* = -150384432 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1525:9
when -150384443 is static:
  const
    YDB_ERR_MLKCLEANED* = -150384443 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1526:9
else:
  let YDB_ERR_MLKCLEANED* = -150384443 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1526:9
when -150384450 is static:
  const
    YDB_ERR_NOTMNAME* = -150384450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1527:9
else:
  let YDB_ERR_NOTMNAME* = -150384450 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1527:9
when -150384458 is static:
  const
    YDB_ERR_DEVNAMERESERVED* = -150384458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1528:9
else:
  let YDB_ERR_DEVNAMERESERVED* = -150384458 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1528:9
when -150384467 is static:
  const
    YDB_ERR_ORLBKREL* = -150384467 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1529:9
else:
  let YDB_ERR_ORLBKREL* = -150384467 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1529:9
when -150384475 is static:
  const
    YDB_ERR_ORLBKRESTART* = -150384475 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1530:9
else:
  let YDB_ERR_ORLBKRESTART* = -150384475 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1530:9
when -150384482 is static:
  const
    YDB_ERR_UNIQNAME* = -150384482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1531:9
else:
  let YDB_ERR_UNIQNAME* = -150384482 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1531:9
when -150384490 is static:
  const
    YDB_ERR_APDINITFAIL* = -150384490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1532:9
else:
  let YDB_ERR_APDINITFAIL* = -150384490 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1532:9
when -150384498 is static:
  const
    YDB_ERR_APDCONNFAIL* = -150384498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1533:9
else:
  let YDB_ERR_APDCONNFAIL* = -150384498 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1533:9
when -150384506 is static:
  const
    YDB_ERR_APDLOGFAIL* = -150384506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1534:9
else:
  let YDB_ERR_APDLOGFAIL* = -150384506 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1534:9
when -150384514 is static:
  const
    YDB_ERR_STATSDBMEMERR* = -150384514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1535:9
else:
  let YDB_ERR_STATSDBMEMERR* = -150384514 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1535:9
when -150384520 is static:
  const
    YDB_ERR_BUFSPCDELAY* = -150384520 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1536:9
else:
  let YDB_ERR_BUFSPCDELAY* = -150384520 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1536:9
when -150384530 is static:
  const
    YDB_ERR_AIOQUEUESTUCK* = -150384530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1537:9
else:
  let YDB_ERR_AIOQUEUESTUCK* = -150384530 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1537:9
when -150384538 is static:
  const
    YDB_ERR_INVGVPATQUAL* = -150384538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1538:9
else:
  let YDB_ERR_INVGVPATQUAL* = -150384538 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1538:9
when -150384544 is static:
  const
    YDB_ERR_NULLPATTERN* = -150384544 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1539:9
else:
  let YDB_ERR_NULLPATTERN* = -150384544 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1539:9
when -150384555 is static:
  const
    YDB_ERR_MLKREHASH* = -150384555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1540:9
else:
  let YDB_ERR_MLKREHASH* = -150384555 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1540:9
when -150384562 is static:
  const
    YDB_ERR_MUKEEPPERCENT* = -150384562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1541:9
else:
  let YDB_ERR_MUKEEPPERCENT* = -150384562 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1541:9
when -150384570 is static:
  const
    YDB_ERR_MUKEEPNODEC* = -150384570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1542:9
else:
  let YDB_ERR_MUKEEPNODEC* = -150384570 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1542:9
when -150384578 is static:
  const
    YDB_ERR_MUKEEPNOTRUNC* = -150384578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1543:9
else:
  let YDB_ERR_MUKEEPNOTRUNC* = -150384578 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1543:9
when -150384587 is static:
  const
    YDB_ERR_MUTRUNCNOSPKEEP* = -150384587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1544:9
else:
  let YDB_ERR_MUTRUNCNOSPKEEP* = -150384587 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1544:9
when -150384594 is static:
  const
    YDB_ERR_TERMHANGUP* = -150384594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1545:9
else:
  let YDB_ERR_TERMHANGUP* = -150384594 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1545:9
when -150384600 is static:
  const
    YDB_ERR_DBFILNOFULLWRT* = -150384600 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1546:9
else:
  let YDB_ERR_DBFILNOFULLWRT* = -150384600 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1546:9
when -150384610 is static:
  const
    YDB_ERR_BADCONNECTPARAM* = -150384610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1547:9
else:
  let YDB_ERR_BADCONNECTPARAM* = -150384610 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1547:9
when -150384618 is static:
  const
    YDB_ERR_BADPARAMCOUNT* = -150384618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1548:9
else:
  let YDB_ERR_BADPARAMCOUNT* = -150384618 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1548:9
when -150384624 is static:
  const
    YDB_ERR_REPLALERT* = -150384624 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1549:9
else:
  let YDB_ERR_REPLALERT* = -150384624 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1549:9
when -150384632 is static:
  const
    YDB_ERR_SHUT2QUICK* = -150384632 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1550:9
else:
  let YDB_ERR_SHUT2QUICK* = -150384632 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1550:9
when -150384640 is static:
  const
    YDB_ERR_REPLNORESP* = -150384640 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1551:9
else:
  let YDB_ERR_REPLNORESP* = -150384640 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1551:9
when -150384649 is static:
  const
    YDB_ERR_REPL0BACKLOG* = -150384649 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1552:9
else:
  let YDB_ERR_REPL0BACKLOG* = -150384649 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1552:9
when -150384658 is static:
  const
    YDB_ERR_REPLBACKLOG* = -150384658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1553:9
else:
  let YDB_ERR_REPLBACKLOG* = -150384658 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1553:9
when -150384666 is static:
  const
    YDB_ERR_INVSHUTDOWN* = -150384666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1554:9
else:
  let YDB_ERR_INVSHUTDOWN* = -150384666 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1554:9
when -150384674 is static:
  const
    YDB_ERR_SOCKBLOCKERR* = -150384674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1555:9
else:
  let YDB_ERR_SOCKBLOCKERR* = -150384674 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1555:9
when -150384682 is static:
  const
    YDB_ERR_SOCKWAITARG* = -150384682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1556:9
else:
  let YDB_ERR_SOCKWAITARG* = -150384682 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1556:9
when -150384691 is static:
  const
    YDB_ERR_LASTTRANS* = -150384691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1557:9
else:
  let YDB_ERR_LASTTRANS* = -150384691 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1557:9
when -150384699 is static:
  const
    YDB_ERR_SRCBACKLOGSTATUS* = -150384699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1558:9
else:
  let YDB_ERR_SRCBACKLOGSTATUS* = -150384699 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1558:9
when -150384707 is static:
  const
    YDB_ERR_BKUPRETRY* = -150384707 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1559:9
else:
  let YDB_ERR_BKUPRETRY* = -150384707 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1559:9
when -150384715 is static:
  const
    YDB_ERR_BKUPPROGRESS* = -150384715 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1560:9
else:
  let YDB_ERR_BKUPPROGRESS* = -150384715 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1560:9
when -150384722 is static:
  const
    YDB_ERR_BKUPFILEPERM* = -150384722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1561:9
else:
  let YDB_ERR_BKUPFILEPERM* = -150384722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1561:9
when -150384730 is static:
  const
    YDB_ERR_AUDINITFAIL* = -150384730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1562:9
else:
  let YDB_ERR_AUDINITFAIL* = -150384730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1562:9
when -150384738 is static:
  const
    YDB_ERR_AUDCONNFAIL* = -150384738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1563:9
else:
  let YDB_ERR_AUDCONNFAIL* = -150384738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1563:9
when -150384746 is static:
  const
    YDB_ERR_AUDLOGFAIL* = -150384746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1564:9
else:
  let YDB_ERR_AUDLOGFAIL* = -150384746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1564:9
when -150384754 is static:
  const
    YDB_ERR_SOCKCLOSE* = -150384754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1565:9
else:
  let YDB_ERR_SOCKCLOSE* = -150384754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors.h:1565:9
when -151027722 is static:
  const
    YDB_ERR_QUERY2* = -151027722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:16:9
else:
  let YDB_ERR_QUERY2* = -151027722 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:16:9
when -151027730 is static:
  const
    YDB_ERR_MIXIMAGE* = -151027730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:17:9
else:
  let YDB_ERR_MIXIMAGE* = -151027730 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:17:9
when -151027738 is static:
  const
    YDB_ERR_LIBYOTTAMISMTCH* = -151027738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:18:9
else:
  let YDB_ERR_LIBYOTTAMISMTCH* = -151027738 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:18:9
when -151027746 is static:
  const
    YDB_ERR_READONLYNOSTATS* = -151027746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:19:9
else:
  let YDB_ERR_READONLYNOSTATS* = -151027746 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:19:9
when -151027754 is static:
  const
    YDB_ERR_READONLYLKFAIL* = -151027754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:20:9
else:
  let YDB_ERR_READONLYLKFAIL* = -151027754 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:20:9
when -151027762 is static:
  const
    YDB_ERR_INVVARNAME* = -151027762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:21:9
else:
  let YDB_ERR_INVVARNAME* = -151027762 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:21:9
when -151027770 is static:
  const
    YDB_ERR_PARAMINVALID* = -151027770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:22:9
else:
  let YDB_ERR_PARAMINVALID* = -151027770 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:22:9
when -151027778 is static:
  const
    YDB_ERR_INSUFFSUBS* = -151027778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:23:9
else:
  let YDB_ERR_INSUFFSUBS* = -151027778 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:23:9
when -151027786 is static:
  const
    YDB_ERR_MINNRSUBSCRIPTS* = -151027786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:24:9
else:
  let YDB_ERR_MINNRSUBSCRIPTS* = -151027786 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:24:9
when -151027794 is static:
  const
    YDB_ERR_SUBSARRAYNULL* = -151027794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:25:9
else:
  let YDB_ERR_SUBSARRAYNULL* = -151027794 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:25:9
when -151027804 is static:
  const
    YDB_ERR_FATALERROR1* = -151027804 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:26:9
else:
  let YDB_ERR_FATALERROR1* = -151027804 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:26:9
when -151027810 is static:
  const
    YDB_ERR_NAMECOUNT2HI* = -151027810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:27:9
else:
  let YDB_ERR_NAMECOUNT2HI* = -151027810 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:27:9
when -151027818 is static:
  const
    YDB_ERR_INVNAMECOUNT* = -151027818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:28:9
else:
  let YDB_ERR_INVNAMECOUNT* = -151027818 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:28:9
when -151027828 is static:
  const
    YDB_ERR_FATALERROR2* = -151027828 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:29:9
else:
  let YDB_ERR_FATALERROR2* = -151027828 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:29:9
when -151027834 is static:
  const
    YDB_ERR_TIME2LONG* = -151027834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:30:9
else:
  let YDB_ERR_TIME2LONG* = -151027834 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:30:9
when -151027842 is static:
  const
    YDB_ERR_VARNAME2LONG* = -151027842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:31:9
else:
  let YDB_ERR_VARNAME2LONG* = -151027842 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:31:9
when -151027850 is static:
  const
    YDB_ERR_SIMPLEAPINEST* = -151027850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:32:9
else:
  let YDB_ERR_SIMPLEAPINEST* = -151027850 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:32:9
when -151027858 is static:
  const
    YDB_ERR_CALLINTCOMMIT* = -151027858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:33:9
else:
  let YDB_ERR_CALLINTCOMMIT* = -151027858 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:33:9
when -151027866 is static:
  const
    YDB_ERR_CALLINTROLLBACK* = -151027866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:34:9
else:
  let YDB_ERR_CALLINTROLLBACK* = -151027866 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:34:9
when -151027874 is static:
  const
    YDB_ERR_TCPCONNTIMEOUT* = -151027874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:35:9
else:
  let YDB_ERR_TCPCONNTIMEOUT* = -151027874 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:35:9
when -151027882 is static:
  const
    YDB_ERR_STDERRALREADYOPEN* = -151027882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:36:9
else:
  let YDB_ERR_STDERRALREADYOPEN* = -151027882 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:36:9
when -151027890 is static:
  const
    YDB_ERR_SETENVFAIL* = -151027890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:37:9
else:
  let YDB_ERR_SETENVFAIL* = -151027890 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:37:9
when -151027898 is static:
  const
    YDB_ERR_UNSETENVFAIL* = -151027898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:38:9
else:
  let YDB_ERR_UNSETENVFAIL* = -151027898 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:38:9
when -151027906 is static:
  const
    YDB_ERR_UNKNOWNSYSERR* = -151027906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:39:9
else:
  let YDB_ERR_UNKNOWNSYSERR* = -151027906 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:39:9
when -151027912 is static:
  const
    YDB_ERR_READLINEFILEPERM* = -151027912 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:40:9
else:
  let YDB_ERR_READLINEFILEPERM* = -151027912 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:40:9
when -151027922 is static:
  const
    YDB_ERR_NODEEND* = -151027922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:41:9
else:
  let YDB_ERR_NODEEND* = -151027922 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:41:9
when -151027928 is static:
  const
    YDB_ERR_READLINELONGLINE* = -151027928 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:42:9
else:
  let YDB_ERR_READLINELONGLINE* = -151027928 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:42:9
when -151027938 is static:
  const
    YDB_ERR_INVTPTRANS* = -151027938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:43:9
else:
  let YDB_ERR_INVTPTRANS* = -151027938 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:43:9
when -151027946 is static:
  const
    YDB_ERR_THREADEDAPINOTALLOWED* = -151027946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:44:9
else:
  let YDB_ERR_THREADEDAPINOTALLOWED* = -151027946 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:44:9
when -151027954 is static:
  const
    YDB_ERR_SIMPLEAPINOTALLOWED* = -151027954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:45:9
else:
  let YDB_ERR_SIMPLEAPINOTALLOWED* = -151027954 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:45:9
when -151027962 is static:
  const
    YDB_ERR_STAPIFORKEXEC* = -151027962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:46:9
else:
  let YDB_ERR_STAPIFORKEXEC* = -151027962 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:46:9
when -151027970 is static:
  const
    YDB_ERR_INVVALUE* = -151027970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:47:9
else:
  let YDB_ERR_INVVALUE* = -151027970 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:47:9
when -151027978 is static:
  const
    YDB_ERR_INVZCONVERT* = -151027978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:48:9
else:
  let YDB_ERR_INVZCONVERT* = -151027978 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:48:9
when -151027986 is static:
  const
    YDB_ERR_ZYSQLNULLNOTVALID* = -151027986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:49:9
else:
  let YDB_ERR_ZYSQLNULLNOTVALID* = -151027986 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:49:9
when -151027994 is static:
  const
    YDB_ERR_BOOLEXPRTOODEEP* = -151027994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:50:9
else:
  let YDB_ERR_BOOLEXPRTOODEEP* = -151027994 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:50:9
when -151028002 is static:
  const
    YDB_ERR_TPCALLBACKINVRETVAL* = -151028002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:51:9
else:
  let YDB_ERR_TPCALLBACKINVRETVAL* = -151028002 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:51:9
when -151028010 is static:
  const
    YDB_ERR_INVMAINLANG* = -151028010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:52:9
else:
  let YDB_ERR_INVMAINLANG* = -151028010 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:52:9
when -151028019 is static:
  const
    YDB_ERR_WCSFLUFAILED* = -151028019 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:53:9
else:
  let YDB_ERR_WCSFLUFAILED* = -151028019 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:53:9
when -151028026 is static:
  const
    YDB_ERR_WORDEXPFAILED* = -151028026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:54:9
else:
  let YDB_ERR_WORDEXPFAILED* = -151028026 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:54:9
when -151028034 is static:
  const
    YDB_ERR_TRANSREPLJNL1GB* = -151028034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:55:9
else:
  let YDB_ERR_TRANSREPLJNL1GB* = -151028034 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:55:9
when -151028042 is static:
  const
    YDB_ERR_DEVPARPARSE* = -151028042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:56:9
else:
  let YDB_ERR_DEVPARPARSE* = -151028042 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:56:9
when -151028050 is static:
  const
    YDB_ERR_SETZDIRTOOLONG* = -151028050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:57:9
else:
  let YDB_ERR_SETZDIRTOOLONG* = -151028050 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:57:9
when -151028058 is static:
  const
    YDB_ERR_UTF8NOTINSTALLED* = -151028058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:58:9
else:
  let YDB_ERR_UTF8NOTINSTALLED* = -151028058 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:58:9
when -151028066 is static:
  const
    YDB_ERR_ISVUNSUPPORTED* = -151028066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:59:9
else:
  let YDB_ERR_ISVUNSUPPORTED* = -151028066 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:59:9
when -151028074 is static:
  const
    YDB_ERR_GVNUNSUPPORTED* = -151028074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:60:9
else:
  let YDB_ERR_GVNUNSUPPORTED* = -151028074 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:60:9
when -151028082 is static:
  const
    YDB_ERR_ISVSUBSCRIPTED* = -151028082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:61:9
else:
  let YDB_ERR_ISVSUBSCRIPTED* = -151028082 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:61:9
when -151028090 is static:
  const
    YDB_ERR_ZBRKCNTNEGATIVE* = -151028090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:62:9
else:
  let YDB_ERR_ZBRKCNTNEGATIVE* = -151028090 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:62:9
when -151028098 is static:
  const
    YDB_ERR_SECSHRPATHMAX* = -151028098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:63:9
else:
  let YDB_ERR_SECSHRPATHMAX* = -151028098 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:63:9
when -151028107 is static:
  const
    YDB_ERR_MUTRUNCALREADY* = -151028107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:64:9
else:
  let YDB_ERR_MUTRUNCALREADY* = -151028107 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:64:9
when -151028112 is static:
  const
    YDB_ERR_ARGSLONGLINE* = -151028112 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:65:9
else:
  let YDB_ERR_ARGSLONGLINE* = -151028112 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:65:9
when -151028122 is static:
  const
    YDB_ERR_ZGBLDIRUNDEF* = -151028122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:66:9
else:
  let YDB_ERR_ZGBLDIRUNDEF* = -151028122 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:66:9
when -151028130 is static:
  const
    YDB_ERR_SHEBANGMEXT* = -151028130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:67:9
else:
  let YDB_ERR_SHEBANGMEXT* = -151028130 ## Generated based on /usr/local/lib/yottadb/r202/libydberrors2.h:67:9
proc ydb_cij*(c_rtn_name: cstring; arg_blob: ptr cstring; count: cint;
              arg_types: ptr cint; io_vars_mask: ptr cuint;
              has_ret_value: ptr cuint): cint {.cdecl, importc: "ydb_cij".}
proc ydb_zstatus*(msg: cstring; len: cint): cint {.cdecl, importc: "ydb_zstatus".}
proc ydb_call_variadic_plist_func*(cgfunc: ydb_vplist_func;
                                   cvplist: ptr gparam_list): cint {.cdecl,
    importc: "ydb_call_variadic_plist_func".}
proc ydb_child_init*(param: pointer): cint {.cdecl, importc: "ydb_child_init".}
proc ydb_ci*(c_rtn_name: cstring): cint {.cdecl, varargs, importc: "ydb_ci".}
proc ydb_cip*(ci_info: ptr ci_name_descriptor): cint {.cdecl, varargs,
    importc: "ydb_cip".}
proc ydb_ci_get_info*(rtnname: cstring; pptype: ptr ci_parm_type): cint {.cdecl,
    importc: "ydb_ci_get_info".}
proc ydb_ci_get_info_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                        rtnname: cstring; pptype: ptr ci_parm_type): cint {.
    cdecl, importc: "ydb_ci_get_info_t".}
proc ydb_ci_tab_open*(fname: cstring; ret_value: ptr uintptr_t): cint {.cdecl,
    importc: "ydb_ci_tab_open".}
proc ydb_ci_tab_switch*(new_handle: uintptr_t; ret_old_handle: ptr uintptr_t): cint {.
    cdecl, importc: "ydb_ci_tab_switch".}
proc ydb_eintr_handler*(): cint {.cdecl, importc: "ydb_eintr_handler".}
proc ydb_exit*(): cint {.cdecl, importc: "ydb_exit".}
proc ydb_file_id_free*(fileid: ydb_fileid_ptr_t): cint {.cdecl,
    importc: "ydb_file_id_free".}
proc ydb_file_is_identical*(fileid1: ydb_fileid_ptr_t; fileid2: ydb_fileid_ptr_t): cint {.
    cdecl, importc: "ydb_file_is_identical".}
proc ydb_file_name_to_id*(filename: ptr ydb_string_t;
                          fileid: ptr ydb_fileid_ptr_t): cint {.cdecl,
    importc: "ydb_file_name_to_id".}
proc ydb_fork_n_core*(): void {.cdecl, importc: "ydb_fork_n_core".}
proc ydb_free*(ptr_arg: pointer): void {.cdecl, importc: "ydb_free".}
proc ydb_hiber_start*(sleep_nsec: culonglong): cint {.cdecl,
    importc: "ydb_hiber_start".}
proc ydb_hiber_start_wait_any*(sleep_nsec: culonglong): cint {.cdecl,
    importc: "ydb_hiber_start_wait_any".}
proc ydb_init*(): cint {.cdecl, importc: "ydb_init".}
proc ydb_main_lang_init*(langid: cint; parm: pointer): cint {.cdecl,
    importc: "ydb_main_lang_init".}
proc ydb_malloc*(size: csize_t): pointer {.cdecl, importc: "ydb_malloc".}
proc ydb_message*(status: cint; msg_buff: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_message".}
proc ydb_sig_dispatch*(errstr: ptr ydb_buffer_t; signum: cint): cint {.cdecl,
    importc: "ydb_sig_dispatch".}
proc ydb_stdout_stderr_adjust*(): cint {.cdecl,
    importc: "ydb_stdout_stderr_adjust".}
proc ydb_thread_is_main*(): cint {.cdecl, importc: "ydb_thread_is_main".}
proc ydb_timer_cancel*(timer_id: intptr_t): void {.cdecl,
    importc: "ydb_timer_cancel".}
proc ydb_timer_start*(timer_id: intptr_t; limit_nsec: culonglong;
                      handler: ydb_funcptr_retvoid_t; hdata_len: cuint;
                      hdata: pointer): cint {.cdecl, importc: "ydb_timer_start".}
proc ydb_ci_t*(tptoken: uint64; errstr: ptr ydb_buffer_t; c_rtn_name: cstring): cint {.
    cdecl, varargs, importc: "ydb_ci_t".}
proc ydb_cip_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                ci_info: ptr ci_name_descriptor): cint {.cdecl, varargs,
    importc: "ydb_cip_t".}
proc ydb_ci_tab_open_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                        fname: cstring; ret_value: ptr uintptr_t): cint {.cdecl,
    importc: "ydb_ci_tab_open_t".}
proc ydb_ci_tab_switch_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                          new_handle: uintptr_t; ret_old_handle: ptr uintptr_t): cint {.
    cdecl, importc: "ydb_ci_tab_switch_t".}
proc ydb_eintr_handler_t*(tptoken: uint64; errstr: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_eintr_handler_t".}
proc ydb_file_id_free_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                         fileid: ydb_fileid_ptr_t): cint {.cdecl,
    importc: "ydb_file_id_free_t".}
proc ydb_file_is_identical_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                              fileid1: ydb_fileid_ptr_t;
                              fileid2: ydb_fileid_ptr_t): cint {.cdecl,
    importc: "ydb_file_is_identical_t".}
proc ydb_file_name_to_id_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                            filename: ptr ydb_string_t;
                            fileid: ptr ydb_fileid_ptr_t): cint {.cdecl,
    importc: "ydb_file_name_to_id_t".}
proc ydb_message_t*(tptoken: uint64; errstr: ptr ydb_buffer_t; status: cint;
                    msg_buff: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_message_t".}
proc ydb_stdout_stderr_adjust_t*(tptoken: uint64; errstr: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_stdout_stderr_adjust_t".}
proc ydb_timer_cancel_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                         timer_id: intptr_t): void {.cdecl,
    importc: "ydb_timer_cancel_t".}
proc ydb_timer_start_t*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                        timer_id: intptr_t; limit_nsec: culonglong;
                        handler: ydb_funcptr_retvoid_t; hdata_len: cuint;
                        hdata: pointer): cint {.cdecl,
    importc: "ydb_timer_start_t".}
proc ydb_data_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; ret_value: ptr cuint): cint {.
    cdecl, importc: "ydb_data_s".}
proc ydb_delete_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                   subsarray: ptr ydb_buffer_t; deltype: cint): cint {.cdecl,
    importc: "ydb_delete_s".}
proc ydb_delete_excl_s*(namecount: cint; varnames: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_delete_excl_s".}
proc ydb_get_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                subsarray: ptr ydb_buffer_t; ret_value: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_get_s".}
proc ydb_incr_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; increment: ptr ydb_buffer_t;
                 ret_value: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_incr_s".}
proc ydb_lock_s*(timeout_nsec: culonglong; namecount: cint): cint {.cdecl,
    varargs, importc: "ydb_lock_s".}
proc ydb_lock_decr_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                      subsarray: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_lock_decr_s".}
proc ydb_lock_incr_s*(timeout_nsec: culonglong; varname: ptr ydb_buffer_t;
                      subs_used: cint; subsarray: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_lock_incr_s".}
proc ydb_node_next_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                      subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                      ret_subsarray: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_node_next_s".}
proc ydb_node_previous_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                          subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                          ret_subsarray: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_node_previous_s".}
proc ydb_set_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                subsarray: ptr ydb_buffer_t; value: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_set_s".}
proc ydb_str2zwr_s*(str: ptr ydb_buffer_t; zwr: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_str2zwr_s".}
proc ydb_subscript_next_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                           subsarray: ptr ydb_buffer_t;
                           ret_value: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_subscript_next_s".}
proc ydb_subscript_previous_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                               subsarray: ptr ydb_buffer_t;
                               ret_value: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_subscript_previous_s".}
proc ydb_tp_s*(tpfn: ydb_tpfnptr_t; tpfnparm: pointer; transid: cstring;
               namecount: cint; varnames: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_tp_s".}
proc ydb_zwr2str_s*(zwr: ptr ydb_buffer_t; str: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_zwr2str_s".}
proc ydb_data_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                  varname: ptr ydb_buffer_t; subs_used: cint;
                  subsarray: ptr ydb_buffer_t; ret_value: ptr cuint): cint {.
    cdecl, importc: "ydb_data_st".}
proc ydb_delete_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                    varname: ptr ydb_buffer_t; subs_used: cint;
                    subsarray: ptr ydb_buffer_t; deltype: cint): cint {.cdecl,
    importc: "ydb_delete_st".}
proc ydb_delete_excl_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                         namecount: cint; varnames: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_delete_excl_st".}
proc ydb_get_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                 varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; ret_value: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_get_st".}
proc ydb_incr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                  varname: ptr ydb_buffer_t; subs_used: cint;
                  subsarray: ptr ydb_buffer_t; increment: ptr ydb_buffer_t;
                  ret_value: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_incr_st".}
proc ydb_lock_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                  timeout_nsec: culonglong; namecount: cint): cint {.cdecl,
    varargs, importc: "ydb_lock_st".}
proc ydb_lock_decr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                       varname: ptr ydb_buffer_t; subs_used: cint;
                       subsarray: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_lock_decr_st".}
proc ydb_lock_incr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                       timeout_nsec: culonglong; varname: ptr ydb_buffer_t;
                       subs_used: cint; subsarray: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_lock_incr_st".}
proc ydb_node_next_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                       varname: ptr ydb_buffer_t; subs_used: cint;
                       subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                       ret_subsarray: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_node_next_st".}
proc ydb_node_previous_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                           varname: ptr ydb_buffer_t; subs_used: cint;
                           subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                           ret_subsarray: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_node_previous_st".}
proc ydb_set_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                 varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; value: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_set_st".}
proc ydb_str2zwr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                     str: ptr ydb_buffer_t; zwr: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_str2zwr_st".}
proc ydb_subscript_next_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                            varname: ptr ydb_buffer_t; subs_used: cint;
                            subsarray: ptr ydb_buffer_t;
                            ret_value: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_subscript_next_st".}
proc ydb_subscript_previous_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                                varname: ptr ydb_buffer_t; subs_used: cint;
                                subsarray: ptr ydb_buffer_t;
                                ret_value: ptr ydb_buffer_t): cint {.cdecl,
    importc: "ydb_subscript_previous_st".}
proc ydb_tp_st*(tptoken: uint64; errstr: ptr ydb_buffer_t; tpfn: ydb_tp2fnptr_t;
                tpfnparm: pointer; transid: cstring; namecount: cint;
                varnames: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_tp_st".}
proc ydb_zwr2str_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                     zwr: ptr ydb_buffer_t; str: ptr ydb_buffer_t): cint {.
    cdecl, importc: "ydb_zwr2str_st".}