#include "tau_xml.h"

#include <cstdio>
#include <unistd.h>

namespace
{

void freeIfSet(void *pMemBlock)
{
    if (pMemBlock != nullptr)
    {
        vos_memFree(pMemBlock);
    }
}

void fuzzDeviceConfig(const TRDP_XML_DOC_HANDLE_T *pDocHnd)
{
    TRDP_MEM_CONFIG_T memConfig = {};
    TRDP_DBG_CONFIG_T dbgConfig = {};
    UINT32 numComPar = 0;
    TRDP_COM_PAR_T *pComPar = nullptr;
    UINT32 numIfConfig = 0;
    TRDP_IF_CONFIG_T *pIfConfig = nullptr;

    tau_readXmlDeviceConfig(pDocHnd, &memConfig, &dbgConfig, &numComPar, &pComPar, &numIfConfig, &pIfConfig);
    freeIfSet(pComPar);
    freeIfSet(pIfConfig);
}

void fuzzInterfaceConfig(const TRDP_XML_DOC_HANDLE_T *pDocHnd)
{
    TRDP_PROCESS_CONFIG_T processConfig = {};
    TRDP_PD_CONFIG_T pdConfig = {};
    TRDP_MD_CONFIG_T mdConfig = {};
    UINT32 numExchgPar = 0;
    TRDP_EXCHG_PAR_T *pExchgPar = nullptr;

    tau_readXmlInterfaceConfig(pDocHnd, "", &processConfig, &pdConfig, &mdConfig, &numExchgPar, &pExchgPar);
    tau_freeTelegrams(numExchgPar, pExchgPar);
}

void fuzzDatasetConfig(const TRDP_XML_DOC_HANDLE_T *pDocHnd)
{
    UINT32 numComId = 0;
    TRDP_COMID_DSID_MAP_T *pComIdDsIdMap = nullptr;
    UINT32 numDataset = 0;
    apTRDP_DATASET_T apDataset = nullptr;

    tau_readXmlDatasetConfig(pDocHnd, &numComId, &pComIdDsIdMap, &numDataset, &apDataset);
    tau_freeXmlDatasetConfig(numComId, pComIdDsIdMap, numDataset, apDataset);
}

void fuzzServiceConfig(const TRDP_XML_DOC_HANDLE_T *pDocHnd)
{
    UINT32 numServiceDefs = 0;
    TRDP_SERVICE_DEF_T *pServiceDefs = nullptr;

    tau_readXmlServiceConfig(pDocHnd, &numServiceDefs, &pServiceDefs);
    freeIfSet(pServiceDefs);
}

void fuzzMappedDevices(const TRDP_XML_DOC_HANDLE_T *pDocHnd)
{
    UINT32 numProcConfig = 0;
    TRDP_PROCESS_CONFIG_T *pProcessConfig = nullptr;

    tau_readXmlMappedDevices(pDocHnd, &numProcConfig, &pProcessConfig);
    freeIfSet(pProcessConfig);
}

void fuzzMappedDeviceConfig(const TRDP_XML_DOC_HANDLE_T *pDocHnd)
{
    UINT32 numIfConfig = 0;
    TRDP_IF_CONFIG_T *pIfConfig = nullptr;

    tau_readXmlMappedDeviceConfig(pDocHnd, "", &numIfConfig, &pIfConfig);
    freeIfSet(pIfConfig);
}

void fuzzMappedInterfaceConfig(const TRDP_XML_DOC_HANDLE_T *pDocHnd)
{
    UINT32 numExchgPar = 0;
    TRDP_EXCHG_PAR_T *pExchgPar = nullptr;

    tau_readXmlMappedInterfaceConfig(pDocHnd, "", "", &numExchgPar, &pExchgPar);
    tau_freeTelegrams(numExchgPar, pExchgPar);
}

} // namespace

int parseXmlBuffer(const uint8_t *data, size_t size)
{
    TRDP_XML_DOC_HANDLE_T docHnd;
    if (tau_prepareXmlMem(const_cast<char *>(reinterpret_cast<const char *>(data)), size, &docHnd) != TRDP_NO_ERR)
    {
        return 1;
    }

    fuzzDeviceConfig(&docHnd);
    fuzzInterfaceConfig(&docHnd);
    fuzzDatasetConfig(&docHnd);
    fuzzServiceConfig(&docHnd);
    fuzzMappedDevices(&docHnd);
    fuzzMappedDeviceConfig(&docHnd);
    fuzzMappedInterfaceConfig(&docHnd);

    tau_freeXmlDoc(&docHnd);
    return 0;
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
