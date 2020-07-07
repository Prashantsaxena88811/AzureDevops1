package test;

import java.io.IOException;

import org.openqa.selenium.support.PageFactory;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import main.TestBase;
import pages.HomePage;

public class HomePageTest extends TestBase{
	
	LoginPageTest loginpagetest = new LoginPageTest();
	@BeforeMethod
	public void setup() throws IOException {
		initialize();
		loginpagetest.loginTest();
	}

	@Test(priority = 1)
	public void recentOpportunityPageTest() {
		HomePage homepage = PageFactory.initElements(driver, HomePage.class); 
		homepage.clickMenu();
		homepage.clickOpportunities();
	}


	//Updated 
	@AfterMethod
	public void tearDown() {
		driver.quit();
	}

}
