package test;

import java.io.IOException;

import org.openqa.selenium.support.PageFactory;
import org.testng.Assert;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import main.CommonActions;
import main.TestBase;
import main.Utils;
import pages.LoginPage;

public class LoginPageTest extends TestBase {

	@BeforeMethod
	public void setup() throws IOException{
		initialize();

	}
	//Commit
	@Test // (priority = 1)
	public void loginPageTitleTest() {
		LoginPage loginpage = PageFactory.initElements(driver, LoginPage.class);
		String title = loginpage.ValidateLoginPageTitle();
		Assert.assertEquals(title, "Login | Salesforce");

	}

	// Comment for Testing
	@Test // (priority = 2)
	public void loginTest(){
		LoginPage loginpage = PageFactory.initElements(driver, LoginPage.class);
		loginpage.setUsername(Utils.getPropertyValue("USERNAME"));
		loginpage.setPassword(Utils.getPropertyValue("PASSWORD"));
		loginpage.clickLogin();
		CommonActions.clearOpenTabs();
	}

	@AfterMethod
	public void tearDown() {
		driver.quit();
	}
}
