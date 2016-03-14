#include <perl_libyaml.h>

/* XXX Make -Wall not complain about 'local_patches' not being used. */
#if !defined(PERL_PATCHLEVEL_H_IMPLICIT)
void xxx_local_patches_xs() { printf("%s", local_patches[0]); }
#endif

static IV
handle_option(HV* obj, const char* option, I32 items, IV value) {
  if (items > 1) {
    hv_store(obj, option, strlen(option), newSViv(value), 0);
    return value;
  } else {
    SV **ret = hv_fetch(obj, option, strlen(option), 0);
    return ret ? SvIVX(*ret) : 0;
  }
}

MODULE = YAML::XS::LibYAML		PACKAGE = YAML::XS::Loader

PROTOTYPES: DISABLE

SV*
new (klass, options=NULL)
    char *klass
    HV *options
  CODE:
    RETVAL = new_loader(klass, options);
  OUTPUT:
    RETVAL

#if 0

void
DESTROY (SV* obj)
  CODE:
    if (obj) {
      SV **hret = hv_fetch((HV*)SvRV(obj), "_loader", sizeof("_loader")-1, 0);
      if (*hret) free(INT2PTR(void*, SvIVX(*hret)));
    }

#endif

void
Load (loader_obj, yaml_string, options=NULL)
    SV *loader_obj
    SV *yaml_string
    HV *options
  INIT:
    char *key;
    I32 len;
    SV *sv;
    HV* opt = (HV*)SvRV(loader_obj);
  PPCODE:
    PL_markstack_ptr++;
    hv_iterinit(opt);
    while(sv = hv_iternextsv(opt, &key, &len))
      hv_store(opt, key, len, sv, 0);
    if (!load_string(loader_obj, yaml_string))
      XSRETURN_UNDEF;
    else
      return;

void
LoadFile (loader_obj, yaml_file, options=NULL)
    SV *loader_obj
    SV *yaml_file
    HV *options
  INIT:
    char *key;
    I32 len;
    SV *sv;
    HV* opt = (HV*)SvRV(loader_obj);
  PPCODE:
    PL_markstack_ptr++;
    hv_iterinit(opt);
    while(sv = hv_iternextsv(opt, &key, &len))
      hv_store(opt, key, len, sv, 0);
    if (!load_file(loader_obj, yaml_file))
      XSRETURN_UNDEF;
    else
      return;

IV
NonStrict(loader_obj, value=0)
    SV *loader_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(loader_obj), "NonStrict", items, value);
  OUTPUT:
    RETVAL

char *
Encoding(loader_obj, value="")
    SV *loader_obj
    char *value
  INIT:
    HV *obj = (HV*)SvRV(loader_obj);
  CODE:
    if (items > 1) {
      hv_store(obj, "Encoding", 8, newSVpvn(value, strlen(value)), 0);
      RETVAL = value;
    } else {
      SV **ret = hv_fetch(obj, "Encoding", 8, 0);
      RETVAL = ret ? SvPVX(*ret) : NULL;
    }
  OUTPUT:
    RETVAL

MODULE = YAML::XS::LibYAML		PACKAGE = YAML::XS::SafeLoader

PROTOTYPES: DISABLE

SV*
new (klass, options=NULL)
    char *klass
    HV *options
  CODE:
    RETVAL = new_loader(klass, options);
  OUTPUT:
    RETVAL

void
SafeLoad (loader_obj, yaml_string, options=NULL)
    SV *loader_obj
    SV *yaml_string
    HV *options
  INIT:
    char *key;
    I32 len;
    SV *sv;
    HV* opt = (HV*)SvRV(loader_obj);
  PPCODE:
    PL_markstack_ptr++;
    hv_iterinit(opt);
    while(sv = hv_iternextsv(opt, &key, &len))
      hv_store(opt, key, len, sv, 0);
    hv_store(opt, "SafeMode", sizeof("SafeMode")-1, &PL_sv_yes, 0);
    if (!load_string(loader_obj, yaml_string))
      XSRETURN_UNDEF;
    else
      return;

void
SafeLoadFile (loader_obj, yaml_file, options=NULL)
    SV *loader_obj
    SV *yaml_file
    HV *options
  INIT:
    char *key;
    I32 len;
    SV *sv;
    HV* opt = (HV*)SvRV(loader_obj);
  PPCODE:
    PL_markstack_ptr++;
    hv_iterinit(opt);
    while(sv = hv_iternextsv(opt, &key, &len))
      hv_store(opt, key, len, sv, 0);
    hv_store(opt, "SafeMode", sizeof("SafeMode")-1, &PL_sv_yes, 0);
    if (!load_file(loader_obj, yaml_file))
      XSRETURN_UNDEF;
    else
      return;

MODULE = YAML::XS::LibYAML		PACKAGE = YAML::XS::Dumper

PROTOTYPES: DISABLE

SV*
new (klass, options=NULL)
    char *klass
    HV *options
  CODE:
    RETVAL = new_dumper(klass, options);
  OUTPUT:
    RETVAL

#if 0

void
DESTROY (SV* obj)
  CODE:
    if (obj) {
      SV **hret = hv_fetch((HV*)SvRV(obj), "_dumper", sizeof("_dumper")-1, 0);
      if (*hret) free(INT2PTR(void*, SvIVX(*hret)));
    }

#endif

void
Dump (dumper_obj, ...)
    SV *dumper_obj;
  PPCODE:
    PL_markstack_ptr++;
    MARK++;
    if (dump_string(dumper_obj))
      XSRETURN_UNDEF;
    else
      XSRETURN_YES;

void
DumpFile (dumper_obj, yaml_file, ...)
    SV *dumper_obj
    SV *yaml_file
  PPCODE:
    PL_markstack_ptr++;
    hv_store((HV*)SvRV(dumper_obj), "SafeMode", sizeof("SafeMode")-1, &PL_sv_no, 0);
    MARK++;
    if (dump_file(dumper_obj, yaml_file))
      XSRETURN_YES;
    else
      XSRETURN_UNDEF;

IV
UseCode(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "UseCode", items, value);
  OUTPUT:
    RETVAL

IV
QuoteNumericStrings(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "QuoteNumericStrings", items, value);
  OUTPUT:
    RETVAL

IV
Unicode(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "Unicode", items, value);
  OUTPUT:
    RETVAL

IV
Indent(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "Indent", items, value);
  OUTPUT:
    RETVAL
    
IV
OpenEnded(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "OpenEnded", items, value);
  OUTPUT:
    RETVAL

IV
IndentlessMap(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "IndentlessMap", items, value);
  OUTPUT:
    RETVAL

IV
BestWidth(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "BestWidth", items, value);
  OUTPUT:
    RETVAL

IV
Canonical(dumper_obj, value=0)
    SV *dumper_obj
    IV value
  CODE:
    RETVAL = handle_option((HV*)SvRV(dumper_obj), "Canonical", items, value);
  OUTPUT:
    RETVAL

char *
Encoding(dumper_obj, value="")
    SV *dumper_obj
    char *value
  INIT:
    HV *obj = (HV*)SvRV(dumper_obj);
  CODE:
    if (items > 1) {
      hv_store(obj, "Encoding", 8, newSVpvn(value, strlen(value)), 0);
      RETVAL = value;
    } else {
      SV **ret = hv_fetch(obj, "Encoding", 8, 0);
      RETVAL = ret ? SvPVX(*ret) : NULL;
    }
  OUTPUT:
    RETVAL

char *
LineBreak(dumper_obj, value="")
    SV *dumper_obj
    char *value
  INIT:
    HV *obj = (HV*)SvRV(dumper_obj);
  CODE:
    if (items > 1) {
      hv_store(obj, "LineBreak", 9, newSVpvn(value, strlen(value)), 0);
      RETVAL = value;
    } else {
      SV **ret = hv_fetch(obj, "LineBreak", 9, 0);
      RETVAL = ret ? SvPVX(*ret) : NULL;
    }
  OUTPUT:
    RETVAL

MODULE = YAML::XS::LibYAML		PACKAGE = YAML::XS::SafeDumper

PROTOTYPES: DISABLE

void
SafeDump (dumper_obj, ...)
    SV *dumper_obj;
  PPCODE:
    PL_markstack_ptr++;
    hv_store((HV*)SvRV(dumper_obj), "SafeMode", sizeof("SafeMode")-1, &PL_sv_yes, 0);
    MARK++;
    if (dump_string(dumper_obj))
      XSRETURN_UNDEF;
    else
      XSRETURN_YES;

void
SafeDumpFile (dumper_obj, yaml_file, ...)
    SV *dumper_obj
    SV *yaml_file
  PPCODE:
    PL_markstack_ptr++;
    hv_store((HV*)SvRV(dumper_obj), "SafeMode", sizeof("SafeMode")-1, &PL_sv_yes, 0);
    MARK++;
    if (dump_file(dumper_obj, yaml_file))
      XSRETURN_YES;
    else
      XSRETURN_UNDEF;

MODULE = YAML::XS::LibYAML		PACKAGE = YAML::XS::LibYAML

PROTOTYPES: DISABLE

void
Load (yaml_string, options=NULL)
    SV *yaml_string
    HV *options
  INIT:
    SV *obj;
  PPCODE:
    PL_markstack_ptr++;
    obj = new_loader("YAML::XS::LibYAML", options);
    if (!load_string(obj, yaml_string))
      XSRETURN_UNDEF;
    else
      return;

void
LoadFile (yaml_file, options=NULL)
    SV *yaml_file
    HV *options
  INIT:
    SV *obj;
  PPCODE:
    PL_markstack_ptr++;
    obj = new_loader("YAML::XS::LibYAML", options);
    if (!load_file(obj, yaml_file))
      XSRETURN_UNDEF;
    else
      return;

void
Dump (...)
  INIT:
    SV *obj;
  PPCODE:
    PL_markstack_ptr++;
    if (SvROK(ST(0)) && SvOBJECT(SvRV(ST(0)))
               && strnEQ(HvNAME(SvRV(ST(0))), "YAML::XS::", 8)) {
      obj = ST(0);
      MARK++;
      dump_string(obj); /* obj->method */
    }
    else {
      obj = new_dumper("YAML::XS::LibYAML", NULL);
      if (SvTYPE(ST(0)) == SVt_PV && strnEQ(SvPVX(ST(0)), "YAML::XS::", 8)) {
        MARK++;   /* class method */
      }
      dump_string(obj);
    }

void
DumpFile (yaml_file, ...)
    SV *yaml_file
  INIT:
    SV *obj;
  PPCODE:
    PL_markstack_ptr++;
    if (SvROK(ST(0)) && SvOBJECT(SvRV(ST(0)))
        && strnEQ(HvNAME(SvRV(ST(0))), "YAML::XS::", 8)) {
      obj = ST(0);
      yaml_file = ST(1);
      MARK++;
      if (dump_file(obj, yaml_file)) /* obj->method */
        XSRETURN_YES;
      else
        XSRETURN_UNDEF;
    }
    else {
      obj = new_dumper("YAML::XS::LibYAML", NULL);
      if (SvTYPE(ST(0)) == SVt_PV && strnEQ(SvPVX(ST(0)), "YAML::XS::", 8)) {
        MARK++;   /* class method */
        yaml_file = ST(1);
      }
      if (dump_file(obj, yaml_file))
        XSRETURN_YES;
      else
        XSRETURN_UNDEF;
    }
