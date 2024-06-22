/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 06-13-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-01-2022   Suresh Beniwal   Initial Version
**/
import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/xlsx";
export default class XlsxMain extends LightningElement {
  @api headerList;
  @api filename;
  @api worksheetNameList;
  @api sheetData;
  librariesLoaded = false;
  renderedCallback() {
    console.log("renderedCallback xlsx");
    if (this.librariesLoaded) return;
    this.librariesLoaded = true;
    Promise.all([loadScript(this, workbook )])
      .then(() => {
        console.log("success");
      })
      .catch(error => {
        console.log("failure");
      });
  }
  @api download() {
    const XLSX = window.XLSX;
    let xlsData = this.sheetData;
    let xlsHeader = this.headerList;
    let ws_name = this.worksheetNameList;
    let createXLSLFormatObj = Array(xlsData.length).fill([]);
    let excelColumnAPI = Array(xlsHeader.length).fill([]);
    //let xlsRowsKeys = [];
    /* form header list */
      xlsHeader.forEach((item, index) => {
        let itemLabel = item.map(function (el) { return el.label; });
        let itemValue = item.map(function (el) { return el.value; });
        createXLSLFormatObj[index] = [itemLabel];
        excelColumnAPI[index] = [itemValue];
      });

    /* form data key list */
      xlsData.forEach((item, selectedRowIndex)=> {
          if (item.length > 0) {
            let xlsRowKey = excelColumnAPI[selectedRowIndex]; // Object.keys(item[0]);
            //item = item.shift();
            item.forEach((value, index) => {
                var innerRowData = [];
                xlsRowKey[0].forEach(item=>{
                    innerRowData.push(value[item]);
                })
                createXLSLFormatObj[selectedRowIndex].push(innerRowData);
            })
          }

      });
    /* creating new Excel */
    var wb = XLSX.utils.book_new();

    /* creating new worksheet */
    var ws = Array(createXLSLFormatObj.length).fill([]);
    for (let i = 0; i < ws.length; i++) {
      /* converting data to excel format and puhing to worksheet */
      let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
      ws[i] = [...ws[i], data];

      /* Add worksheet to Excel */
      XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
    }

    /* Write Excel and Download */
    XLSX.writeFile(wb, this.filename);
  }
}