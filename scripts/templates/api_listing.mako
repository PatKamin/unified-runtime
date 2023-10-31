<%!
import re
from templates import helper as th
from templates import print_helper as tph
%>

==============================
${groupname} API
==============================
|full_name| Specification - Version |spec_version|

%for s in specs:
<%
    name = s['name']
    title = name.capitalize()
    header = s['header']
    objects = s['objects']
    needstitle = True
%>\
#################################################################
## Generate section title and links table
#################################################################
## -------------------------
## Functions
## -------------------------
 <%isempty = True%>
%for obj in objects:
%if re.match(r"function", obj['type']) and ("condition" not in obj):
%if isempty: # only display section title if there is content.
%if needstitle:
<%needstitle = False%>
${title}
============================================================
%endif
* Functions

<%isempty = False%>
%endif
    * :ref:`${th.make_func_name(n, tags, obj).replace("_", "-")}`
%endif
%endfor # obj in objects

#################################################################
## -------------------------
## Enums
## -------------------------
 <%isempty = True%>
%for obj in objects:
%if re.match(r"enum", obj['type']):
%if isempty: # only display section title if there is content.
%if needstitle:
<%needstitle = False%>
${title}
============================================================
%endif
* Enumerations

<%isempty = False%>
%endif
    * :ref:`${th.make_type_name(n, tags, obj).replace("_", "-")}`
%endif
%endfor # obj in objects

#################################################################
## -------------------------
## Structs/Unions
## -------------------------
 <%isempty = True%>
%for obj in objects:
%if re.match(r"struct|union", obj['type']):
%if isempty: # only display section title if there is content.
%if needstitle:
<%needstitle = False%>
${title}
============================================================
%endif
* Structures

<%isempty = False%>
%endif
    * :ref:`${th.make_type_name(n, tags, obj).replace("_", "-")}`
%endif
%endfor # obj in objects

#################################################################
## -------------------------
## Macros
## -------------------------
 <%isempty = True%>
 <%seen = list() %>
%for obj in objects:
%if re.match(r"macro", obj['type']):
%if obj['name'] in seen:
    <% continue %>
%else:
    <% seen.append(obj['name'])%>
%endif
%if isempty: # only display section title if there is content.
%if needstitle:
<%needstitle = False%>
${title}
============================================================
%endif
* Macros

<%isempty = False%>
%endif
    * :ref:`${th.make_type_name(n, tags, obj).replace("_", "-")}`
%endif
%endfor # obj in objects

#################################################################
## -------------------------
## Typedefs
## -------------------------
 <%isempty = True%>
%for obj in objects:
%if re.match(r"typedef", obj['type']) or re.match(r"fptr_typedef", obj['type']):
%if isempty: # only display section title if there is content.
%if needstitle:
<%needstitle = False%>
${title}
============================================================
%endif
* Typedefs

<%isempty = False%>
%endif
    * :ref:`${th.make_type_name(n, tags, obj).replace("_", "-")}`
%endif
%endfor # obj in objects

#################################################################
## Generate API documentation
#################################################################
## -------------------------
## Functions
## -------------------------
<%isempty = True%>
%for obj in objects:
%if re.match(r"function", obj['type']) and ("condition" not in obj):
%if isempty: # only display section title if there is content.
${title} Functions
------------------------------------------------------------------------------
<%isempty = False%>
%endif

.. _${th.make_func_name(n, tags, obj).replace("_", "-")}:

${th.make_func_name(n, tags, obj)}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: ${th.make_func_name(n, tags, obj)}
    :project: UnifiedRuntime

%endif
%endfor # obj in objects

#################################################################
## -------------------------
## Enums
## -------------------------
<%isempty = True%>
%for obj in objects:
%if re.match(r"enum", obj['type']):
%if isempty: # only display section title if there is content.
${title} Enums
------------------------------------------------------------------------------
<%isempty = False%>
%endif

.. _${th.make_type_name(n, tags, obj).replace("_", "-")}:

${th.make_type_name(n, tags, obj)}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenenum:: ${th.make_enum_name(n, tags, obj)}
    :project: UnifiedRuntime

%endif
%endfor # obj in objects
#################################################################
## -------------------------
## Structs/Unions
## -------------------------
 <%isempty = True%>
%for obj in objects:
%if re.match(r"struct|union", obj['type']):
%if isempty: # only display section title if there is content.
${title} Structures
------------------------------------------------------------------------------
<%isempty = False%>
%endif
.. _${th.make_type_name(n, tags, obj).replace("_", "-")}:

${th.make_type_name(n, tags, obj)}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%if re.match(r"struct", obj['type']):
.. doxygenstruct:: ${th.make_type_name(n, tags, obj)}
    :project: UnifiedRuntime
    :members:
    :undoc-members:
%endif
%if re.match(r"union", obj['type']):
.. doxygenunion:: ${th.make_type_name(n, tags, obj)}
    :project: UnifiedRuntime
%endif

%endif
%endfor # obj in objects

#################################################################
## -------------------------
## Macros
## -------------------------
 <%isempty = True%>
 <%seen = list() %>
%for obj in objects:
%if not re.match(r"macro", obj['type']):
<% continue %>
%endif # macro
%if obj['name'] in seen:
    <% continue %>
%else:
    <% seen.append(obj['name']) %>
%endif
%if isempty:
${title} Macros
--------------------------------------------------------------------------------
<%isempty = False%>
%endif # isempty
.. _${th.make_type_name(n, tags, obj).replace("_", "-")}:

${th.make_type_name(n, tags, obj)}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygendefine:: ${th.make_type_name(n, tags, obj)}
    :project: UnifiedRuntime
%endfor # obj in objects

#################################################################
## -------------------------
## Typedefs
## -------------------------
 <%isempty = True%>
%for obj in objects:
%if re.match(r"typedef", obj['type']) or re.match(r"fptr_typedef", obj['type']):
%if isempty: # only display section title if there is content.
${title} Typedefs
--------------------------------------------------------------------------------
<%isempty = False%>
%endif
.. _${th.make_type_name(n, tags, obj).replace("_", "-")}:

${th.make_type_name(n, tags, obj)}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygentypedef:: ${th.make_type_name(n, tags, obj)}
    :project: UnifiedRuntime


%endif
%endfor # obj in objects

%endfor # s in specs

#################################################################
## Print API not part of the spec, needs to be generated separately
#################################################################
<%
    x = tags['$x']
    api_types_funcs = tph.get_api_types_funcs(specs, meta, namespace, tags)
%>\
## Generate Print API links table
Print
============================================================
* Functions
%for func in api_types_funcs:
    * :ref:`${func.c_name.replace("_", "-")}`
%endfor

## 'Extras' functions
    * :ref:`${x}PrintFunctionParams`

<%def name="generate_api_doc(func_name)">\
.. _${func_name.replace("_", "-")}:

${func_name}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: ${func_name}
    :project: UnifiedRuntime
</%def>

## Generate Print API documentation
Print Functions
------------------------------------------------------------------------------
%for func in api_types_funcs:
${generate_api_doc(func.c_name)}
%endfor

## 'Extras' functions
${generate_api_doc(f'{x}PrintFunctionParams')}
