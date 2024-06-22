public with sharing class TranseraUserModel {

    public String sfUsename {get;set;}
    public String xeraLogin {get;set;}
    public String password  {get;set;}
    public String tenant {get;set;}
   
    public TranseraUserModel () {
    }

    public TranseraUserModel (final String sfUsename , final String xeraLogin, final String password, final String tenant) {
        this.sfUsename = sfUsename;
        this.xeraLogin = xeraLogin;
        this.password = password;
        this.tenant = tenant;
    }
   
}