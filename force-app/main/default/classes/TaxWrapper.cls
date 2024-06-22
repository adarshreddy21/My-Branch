public class TaxWrapper {
    Public class TaxDet
    {
   public String ExemptCertId { get; set; }
   public String CertificateNum { get; set; }
   public String CustNum { get; set; }
   public string LastUpdateDate { get; set; }
   public String LastUpdateby { get; set; }
   public String FromDate { get; set; }
   public string ToDate { get; set; }
   public String Long_Code { get; set; }
   public String Status { get; set; }
   public String CertUse { get; set; }
    public String Region { get; set; }
    public String authority { get; set; }  
    }
    
    Public List<TaxDet> Details{get; Set;}


}