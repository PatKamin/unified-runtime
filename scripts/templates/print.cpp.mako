<%!
import re
from templates import helper as th
%><%
    n=namespace
    N=n.upper()

    x=tags['$x']
    X=x.upper()
%>/*
 *
 * Copyright (C) 2023 Intel Corporation
 *
 * Part of the Unified-Runtime Project, under the Apache License v2.0 with LLVM Exceptions.
 * See LICENSE.TXT
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 * @file ${n}_print.cpp
 *
 */

#include "${n}_print.h"
#include "${n}_print.hpp"

#include <algorithm>
#include <sstream>
#include <string.h>

using namespace ${x}::print;

<%def name="ss_copy(item_name)">\
    std::stringstream ss;
    ss << ${item_name};
    return str_copy(&ss, buff, buff_size, out_size);
</%def>

${x}_result_t str_copy(std::stringstream *ss, char *buff, const size_t buff_size, size_t *out_size) {
    size_t c_str_size = strlen(ss->str().c_str()) + 1;
    if (out_size) {
        *out_size = c_str_size;
    }
    if (buff_size < c_str_size) {
        return ${X}_RESULT_ERROR_INVALID_SIZE;
    }
#if defined(_WIN32)
    strncpy_s(buff, buff_size, ss->str().c_str(), c_str_size);
#else
    strncpy(buff, ss->str().c_str(), std::min(buff_size, c_str_size));
#endif
    return ${X}_RESULT_SUCCESS;
}

%for spec in specs:
%for obj in spec['objects']:
## ENUM #######################################################################
%if re.match(r"enum", obj['type']):
    ur_result_t ${th.make_func_name_with_prefix('urPrint', obj['name'])}(enum ${th.make_enum_name(n, tags, obj)} value, char *buff, const size_t buff_size, size_t *out_size) {
        if (!buff) {
            return ${X}_RESULT_ERROR_INVALID_NULL_POINTER;
        }
        
        ${ss_copy("value")}
    }

## STRUCT #####################################################################
%elif re.match(r"struct", obj['type']):
    ur_result_t ${th.make_func_name_with_prefix('urPrint', obj['name'])}(const ${obj['type']} ${th.make_type_name(n, tags, obj)} params, char *buff, const size_t buff_size, size_t *out_size) {
        if (!buff) {
            return ${X}_RESULT_ERROR_INVALID_NULL_POINTER;
        }
        
        ${ss_copy("params")}
    }

%endif
%endfor # obj in spec['objects']
%endfor

%for tbl in th.get_pfncbtables(specs, meta, n, tags):
%for obj in tbl['functions']:
<%
    name = th.make_pfncb_param_type(n, tags, obj)
%>\
ur_result_t ${th.make_func_name_with_prefix('urPrint', name)}(const struct ${th.make_pfncb_param_type(n, tags, obj)} *params, char *buff, const size_t buff_size, size_t *out_size) {
    if (!buff) {
        return ${X}_RESULT_ERROR_INVALID_NULL_POINTER;
    }
    
    ${ss_copy("params")}
}

%endfor
%endfor

ur_result_t urPrintFunctionParams(enum ur_function_t function, const void *params, char *buff, const size_t buff_size, size_t *out_size) {
    if (!params || !buff) {
        return ${X}_RESULT_ERROR_INVALID_NULL_POINTER;
    }
    
    std::stringstream ss;
    switch(function) {
    %for tbl in th.get_pfncbtables(specs, meta, n, tags):
    %for obj in tbl['functions']:
        case ${th.make_func_etor(n, tags, obj)}: {
            ss << (const struct ${th.make_pfncb_param_type(n, tags, obj)} *)params;
            return str_copy(&ss, buff, buff_size, out_size);
        }
    %endfor
    %endfor
        default:
            return ${X}_RESULT_ERROR_INVALID_ENUMERATION;
    }
}
