#include "tau_xml.h"

#include <cstdio>

int main()
{
    const CHAR8 *path = reinterpret_cast<const CHAR8 *>("test.xml");

    TRDP_XML_DOC_HANDLE_T docHnd;
    TRDP_ERR_T err = tau_prepareXmlDoc(path, &docHnd);
    if (err != TRDP_NO_ERR)
    {
        std::fprintf(stderr, "tau_prepareXmlDoc failed with error %d\n", err);
        return 1;
    }

    TRDP_MEM_CONFIG_T memConfig = {};
    TRDP_DBG_CONFIG_T dbgConfig = {};
    UINT32 numComPar = 0;
    TRDP_COM_PAR_T *pComPar = nullptr;
    UINT32 numIfConfig = 0;
    TRDP_IF_CONFIG_T *pIfConfig = nullptr;

    err = tau_readXmlDeviceConfig(&docHnd, &memConfig, &dbgConfig, &numComPar, &pComPar, &numIfConfig, &pIfConfig);
    if (err != TRDP_NO_ERR)
    {
        std::fprintf(stderr, "tau_readXmlDeviceConfig failed with error %d\n", err);
        tau_freeXmlDoc(&docHnd);
        return 1;
    }

    std::printf("Parsed %u com parameter(s) and %u interface(s) from %s\n", numComPar, numIfConfig, path);

    tau_freeXmlDoc(&docHnd);
    return 0;
}
