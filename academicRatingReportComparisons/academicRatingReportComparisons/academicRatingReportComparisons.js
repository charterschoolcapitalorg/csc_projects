import { LightningElement, wire, track } from "lwc";
import getAccountData from "@salesforce/apex/AcademicRatingReportComparisonsCtrl.getSchoolData";

const columns = [
  {
    label: "State",
    fieldName: "StateName",
    initialWidth: 60,
    hideDefaultActions: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "School",
    fieldName: "SchoolUrl",
    type: "url",
    initialWidth: 300,
    typeAttributes: {
      label: { fieldName: "SchoolName" },
      target: "_blank"
    },
    hideDefaultActions: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Property",
    fieldName: "PropertyNickName",
    initialWidth: 110,
    hideDefaultActions: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Owner",
    fieldName: "PropertyOwner",
    initialWidth: 110,
    hideDefaultActions: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Charter Exp.",
    fieldName: "CharterExpirationDate",
    type: "date-local",
    initialWidth: 150,
    hideDefaultActions: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Grades Served",
    fieldName: "GradeServed",
    initialWidth: 220,
    hideDefaultActions: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Color",
    fieldName: "CRCurrentYear",
    initialWidth: 120,
    hideDefaultActions: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Actual",
    fieldName: "TGCurrentYear",
    initialWidth: 275,
    hideDefaultActions: false,
    wrapText: true,
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Comparisons",
    fieldName: "Comparisons",
    initialWidth: 1500,
    hideDefaultActions: false,
    wrapText: true,
    cellAttributes: { alignment: "left" }
  }
];

var element;

const d = new Date();
let previousFY; 
let currentFYstart;
let currentFYend;
let month = d.getMonth();
if(month >= 7 && month <= 12) {
    currentFYstart = (d.getYear()).toString().substr(-2);
    currentFYend = (d.getYear() + 1).toString().substr(-2);
} else {
    currentFYstart = (d.getYear() - 1).toString().substr(-2);
    currentFYend = (d.getYear()).toString().substr(-2);
}
let currentFY = currentFYstart + '-' + currentFYend;
// USE THIS ARRAY TO FIND PRIOR FY, ADD YEARS TO THE BOTTOM
const prevFYArray = [
    {label: "21-22", value: "20-21"}, 
    {label: "22-23", value: "21-22"},
    {label: "23-24", value: "22-23"},
    {label: "24-25", value: "23-24"},
    {label: "25-26", value: "24-25"},
    {label: "26-27", value: "25-26"}
];
const myFy = prevFYArray.find(fy => fy.label === currentFY);
previousFY = myFy.value;
console.log('@@@ currentFY = ' + currentFY + '; prior FY = ' + previousFY);

export default class AcademicRatingReportComparisons extends LightningElement {
    @track columns = columns;
  searchKey = previousFY;
  searchOwner = "";
  @track data;
  @track error;
  fyOptions = [
    { label: "23-24", value: "23-24" },
    { label: "22-23", value: "22-23" },
    { label: "21-22", value: "21-22" },
    { label: "20-21", value: "20-21" },
    { label: "19-20", value: "19-20" },
    { label: "18-19", value: "18-19" },
    { label: "17-18", value: "17-18" },
    { label: "16-17", value: "16-17" },
    { label: "15-16", value: "15-16" },
    { label: "14-15", value: "14-15" }
  ];
  ownerOptions = [
    { label: "All", value: "All" },
    { label: "CSC Owned", value: "CSC Owned" },
    { label: "WFCS I", value: "WFCS I" },
    { label: "WFCS II", value: "WFCS II" }
  ];

  @wire(getAccountData, { searchKey: previousFY, searchOwner: 'All' }) accountList(result) {
    this.data = result.data;
  }

  handleYearOnChange(event) {
    this.searchKey = event.target.value;
    console.log('@@@ searchKey = ' + this.searchKey);
    console.log('@@@ searchOwner = ' + this.searchOwner);
    getAccountData({ searchKey: this.searchKey, searchOwner: this.searchOwner })
      .then((result) => {
        this.data = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleOwnerOnChange(event) {
    this.searchOwner = event.target.value;
    console.log('@@@ searchOwner = ' + this.searchOwner);
    console.log('@@@ searchKey = ' + this.searchKey);
    getAccountData({ searchKey: this.searchKey, searchOwner: this.searchOwner })
      .then((result) => {
        this.data = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  // this method validates the data and creates the csv file to download
  downloadCSVFile() {   
    let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        // this.columns.forEach(item => {            
        //     doc += '<th>'+ item +'</th>'           
        // });
        // my header
        doc += '<th>State</th>'; 
        doc += '<th>School</th>'; 
        doc += '<th>Property</th>';
        doc += '<th>Owner</th>'; 
        doc += '<th>Charter Exp</th>'; 
        doc += '<th>Grades Served</th>'; 
        doc += '<th>Color</th>';
        doc += '<th>Actual</th>'; 
        doc += '<th>Comparisons</th>';
        // my header
        doc += '</tr>';
        // Add the data rows
        this.data.forEach(record => {
            doc += '<tr>';
            doc += '<th>'+record.StateName+'</th>'; 
            doc += '<th>'+record.SchoolName+'</th>'; 
            doc += '<th>'+record.PropertyNickName+'</th>';
            doc += '<th>'+record.PropertyOwner+'</th>'; 
            doc += '<th>'+record.CharterExpirationDate+'</th>'; 
            doc += '<th>'+record.GradeServed+'</th>'; 
            doc += '<th>'+record.CRCurrentYear+'</th>';
            doc += '<th>'+record.TGCurrentYear+'</th>'; 
            doc += '<th>'+record.Comparisons+'</th>';
            doc += '</tr>';
        });
        doc += '</table>';
        element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'AUM_AR_Comparisons.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

}
