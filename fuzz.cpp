#include "tau_xml.h"

#include <cstdio>
#include <unistd.h>

int parseXmlBuffer(const uint8_t *data, size_t size)
{
    TRDP_XML_DOC_HANDLE_T docHnd;
    if (tau_prepareXmlMem(const_cast<char *>(reinterpret_cast<const char *>(data)), size, &docHnd) != TRDP_NO_ERR)
    {
        return 1;
    }

    TRDP_MEM_CONFIG_T memConfig = {};
    TRDP_DBG_CONFIG_T dbgConfig = {};
    UINT32 numComPar = 0;
    TRDP_COM_PAR_T *pComPar = nullptr;
    UINT32 numIfConfig = 0;
    TRDP_IF_CONFIG_T *pIfConfig = nullptr;

    TRDP_ERR_T err = tau_readXmlDeviceConfig(&docHnd, &memConfig, &dbgConfig, &numComPar, &pComPar, &numIfConfig, &pIfConfig);
    vos_memFree(pComPar);
    vos_memFree(pIfConfig);
    tau_freeXmlDoc(&docHnd);
    return (err == TRDP_NO_ERR) ? 0 : 1;
}

__AFL_FUZZ_INIT();

int main()
{
    unsigned char *buf = __AFL_FUZZ_TESTCASE_BUF;

    while (__AFL_LOOP(10000)) {
        size_t len = static_cast<size_t>(__AFL_FUZZ_TESTCASE_LEN);
        if (len > 8) {
            const uint8_t *xml_data = reinterpret_cast<const uint8_t*>(buf);
            parseXmlBuffer(xml_data, len);
        }
    }
    return 0;
}
