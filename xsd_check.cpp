// Validates an XML file against an XSD schema using libxml2.
//
// Usage: xsd_check [-v] <schema.xsd> <input.xml>
//
// Exit codes / stdout verdict:
//   0  VALID      -- well-formed and schema-valid
//   1  INVALID    -- well-formed but fails schema validation
//   2  MALFORMED  -- not even well-formed XML
//   3  usage/schema-load error (details on stderr)


#include <libxml/parser.h>
#include <libxml/xmlschemastypes.h>

#include <cstdio>
#include <cstring>

namespace
{

void silentErrorHandler(void * , const char *, ...) {}

} // namespace

int main(int argc, char **argv)
{
    int argi = 1;
    bool verbose = false;
    if (argc > argi && std::strcmp(argv[argi], "-v") == 0)
    {
        verbose = true;
        ++argi;
    }

    if (argc - argi != 2)
    {
        std::fprintf(stderr, "usage: xsd_check [-v] <schema.xsd> <input.xml>\n");
        return 3;
    }

    const char *xsdPath = argv[argi];
    const char *xmlPath = argv[argi + 1];

    if (!verbose)
    {
        xmlSetGenericErrorFunc(nullptr, silentErrorHandler);
        xmlSetStructuredErrorFunc(nullptr, nullptr);
    }

    xmlDocPtr doc = xmlReadFile(xmlPath, nullptr, XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
    if (doc == nullptr)
    {
        std::printf("MALFORMED %s\n", xmlPath);
        return 2;
    }

    xmlSchemaParserCtxtPtr parserCtxt = xmlSchemaNewParserCtxt(xsdPath);
    if (parserCtxt == nullptr)
    {
        std::fprintf(stderr, "error: could not create schema parser context for %s\n", xsdPath);
        xmlFreeDoc(doc);
        return 3;
    }

    xmlSchemaPtr schema = xmlSchemaParse(parserCtxt);
    xmlSchemaFreeParserCtxt(parserCtxt);
    if (schema == nullptr)
    {
        std::fprintf(stderr, "error: could not parse schema %s\n", xsdPath);
        xmlFreeDoc(doc);
        return 3;
    }

    xmlSchemaValidCtxtPtr validCtxt = xmlSchemaNewValidCtxt(schema);
    int result = xmlSchemaValidateDoc(validCtxt, doc);

    xmlSchemaFreeValidCtxt(validCtxt);
    xmlSchemaFree(schema);
    xmlFreeDoc(doc);

    if (result == 0)
    {
        std::printf("VALID %s\n", xmlPath);
        return 0;
    }

    std::printf("INVALID %s\n", xmlPath);
    return 1;
}
