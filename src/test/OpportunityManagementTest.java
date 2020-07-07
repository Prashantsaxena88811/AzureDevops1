package test;

import java.io.IOException;

import org.openqa.selenium.support.PageFactory;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import main.CommonActions;
import main.TestBase;
import pages.BillingTicketPage;
import pages.OpportunityPage;

public class OpportunityManagementTest extends TestBase {
	
	LoginPageTest loginPageTest = new LoginPageTest();
	HomePageTest homePageTest = new HomePageTest();
	

	@BeforeMethod
	public void setup() throws IOException, InterruptedException {
		initialize();
		loginPageTest.loginTest();
		homePageTest.recentOpportunityPageTest();
	}
	
	@Test
	public void creditCardSelection() {
		OpportunityPage opppage = PageFactory.initElements(driver, OpportunityPage.class);
		opppage.opportuntiesSelection();
		opppage.clickBillingEdit();
		opppage.selectCreditCard();
		opppage.saveButton();
		opppage.openBillingTicket();
		opppage.openBillingEmailLink();
		CommonActions.swtichNextWindow();
		BillingTicketPage billingpage = PageFactory.initElements(driver, BillingTicketPage.class);
		billingpage.setRegStreet("Test Reg Street 123");
		billingpage.setRegCity("New Delhi");
		billingpage.setRegState("Delhi");
		billingpage.setRegCountry("India");
		billingpage.setRegZipCode("110074");
		
	}
	
	@AfterMethod
	public void tearDown() {
//		driver.quit();
	}
}

