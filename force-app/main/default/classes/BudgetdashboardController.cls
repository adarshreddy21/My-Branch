public class BudgetdashboardController {
    
public pageReference openDashBoard(){
        user u = [select is_the_Sales_Manager__c from User Where Id = :UserInfo.getUserId()];
    if(u.is_the_Sales_Manager__c){
        PageReference pg = new PageReference('/'+system.label.dashboardId);
        pg.setRedirect(true);   
        return pg;
    }
    else return new PageReference('/'+system.label.dashboardId2);

    }
}