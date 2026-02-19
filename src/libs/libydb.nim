const
  YDB_DEL_TREE* = cuint(1)
  YDB_DEL_NODE* = cuint(2)


type
  struct_ydb_buffer_t* {.pure, inheritable, bycopy.} = object
    len_alloc*: cuint
    len_used*: cuint
    buf_addr*: cstring
  ydb_buffer_t* = struct_ydb_buffer_t

  ydb_tpfnptr_t* = proc (a0: pointer): cint {.cdecl.}
  ydb_tp2fnptr_t* = proc (a0: uint64; a1: ptr ydb_buffer_t; a2: pointer): cint {.cdecl.}


proc ydb_message*(status: cint; msg_buff: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_message".}

proc ydb_message_t*(tptoken: uint64; errstr: ptr ydb_buffer_t; status: cint; msg_buff: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_message_t".}

proc ydb_ci*(c_rtn_name: cstring): cint {.cdecl, varargs, importc: "ydb_ci".}

proc ydb_ci_t*(tptoken: uint64; errstr: ptr ydb_buffer_t; c_rtn_name: cstring): cint {.cdecl, varargs, importc: "ydb_ci_t".}

proc ydb_data_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; ret_value: ptr cuint): cint {.cdecl, importc: "ydb_data_s".}

proc ydb_delete_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                   subsarray: ptr ydb_buffer_t; deltype: cint): cint {.cdecl, importc: "ydb_delete_s".}

proc ydb_delete_excl_s*(namecount: cint; varnames: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_delete_excl_s".}

proc ydb_get_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                subsarray: ptr ydb_buffer_t; ret_value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_get_s".}

proc ydb_incr_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; Increment: ptr ydb_buffer_t;
                 ret_value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_incr_s".}

proc ydb_lock_s*(timeout_nsec: culonglong; namecount: cint): cint {.cdecl, varargs, importc: "ydb_lock_s".}

proc ydb_lock_decr_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                      subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_lock_decr_s".}

proc ydb_lock_incr_s*(timeout_nsec: culonglong; varname: ptr ydb_buffer_t;
                      subs_used: cint; subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_lock_incr_s".}

proc ydb_node_next_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                      subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                      ret_subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_node_next_s".}

proc ydb_node_previous_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                          subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                          ret_subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_node_previous_s".}

proc ydb_set_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                subsarray: ptr ydb_buffer_t; value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_set_s".}

proc ydb_subscript_next_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                           subsarray: ptr ydb_buffer_t;
                           ret_value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_subscript_next_s".}

proc ydb_subscript_previous_s*(varname: ptr ydb_buffer_t; subs_used: cint;
                               subsarray: ptr ydb_buffer_t;
                               ret_value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_subscript_previous_s".}

proc ydb_tp_s*(tpfn: ydb_tpfnptr_t; tpfnparm: pointer; transid: cstring;
               namecount: cint; varnames: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_tp_s".}



proc ydb_data_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                  varname: ptr ydb_buffer_t; subs_used: cint;
                  subsarray: ptr ydb_buffer_t; ret_value: ptr cuint): cint {.cdecl, importc: "ydb_data_st".}

proc ydb_delete_excl_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                         namecount: cint; varnames: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_delete_excl_st".}

proc ydb_delete_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                    varname: ptr ydb_buffer_t; subs_used: cint;
                    subsarray: ptr ydb_buffer_t; deltype: cint): cint {.cdecl, importc: "ydb_delete_st".}

proc ydb_get_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                 varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; ret_value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_get_st".}

proc ydb_incr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                  varname: ptr ydb_buffer_t; subs_used: cint;
                  subsarray: ptr ydb_buffer_t; Increment: ptr ydb_buffer_t;
                  ret_value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_incr_st".}

proc ydb_lock_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                  timeout_nsec: culonglong; namecount: cint): cint {.cdecl, varargs, importc: "ydb_lock_st".}

proc ydb_lock_decr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                       varname: ptr ydb_buffer_t; subs_used: cint;
                       subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_lock_decr_st".}

proc ydb_lock_incr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                       timeout_nsec: culonglong; varname: ptr ydb_buffer_t;
                       subs_used: cint; subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_lock_incr_st".}

proc ydb_node_next_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                       varname: ptr ydb_buffer_t; subs_used: cint;
                       subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                       ret_subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_node_next_st".}

proc ydb_node_previous_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                           varname: ptr ydb_buffer_t; subs_used: cint;
                           subsarray: ptr ydb_buffer_t; ret_subs_used: ptr cint;
                           ret_subsarray: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_node_previous_st".}

proc ydb_set_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                 varname: ptr ydb_buffer_t; subs_used: cint;
                 subsarray: ptr ydb_buffer_t; value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_set_st".}

proc ydb_subscript_next_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                            varname: ptr ydb_buffer_t; subs_used: cint;
                            subsarray: ptr ydb_buffer_t;
                            ret_value: ptr ydb_buffer_t): cint {.cdecl,importc: "ydb_subscript_next_st".}

proc ydb_subscript_previous_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                                varname: ptr ydb_buffer_t; subs_used: cint;
                                subsarray: ptr ydb_buffer_t;
                                ret_value: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_subscript_previous_st".}

proc ydb_tp_st*(tptoken: uint64; errstr: ptr ydb_buffer_t; tpfn: ydb_tp2fnptr_t;
                tpfnparm: pointer; transid: cstring; namecount: cint;
                varnames: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_tp_st".}

proc ydb_str2zwr_s*(str: ptr ydb_buffer_t; zwr: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_str2zwr_s".}

proc ydb_str2zwr_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                     str: ptr ydb_buffer_t; zwr: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_str2zwr_st".}

proc ydb_zwr2str_s*(zwr: ptr ydb_buffer_t; str: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_zwr2str_s".}

proc ydb_zwr2str_st*(tptoken: uint64; errstr: ptr ydb_buffer_t;
                     zwr: ptr ydb_buffer_t; str: ptr ydb_buffer_t): cint {.cdecl, importc: "ydb_zwr2str_st".}                     

