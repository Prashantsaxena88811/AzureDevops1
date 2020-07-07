package main;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.lang.model.element.Element;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class TestBase {

	public static WebDriver driver;

//  @BeforeSuite
	public void initialize() throws IOException {
		String browserName = Utils.getPropertyValue("BROWSER");

		if (browserName.equals("chrome")) {
			String current = System.getProperty("user.dir");
			System.setProperty("webdriver.chrome.driver",
					current + "//chromedriver.exe");
			ChromeOptions options = new ChromeOptions();
			options.addArguments("--incognito");
			options.addArguments("--disable-extensions");
			options.addArguments("disable-infobars");
			driver = new ChromeDriver(options);
		}

		else if (browserName.equals("firefox")) {
			System.setProperty("webdriver.gecko.driver", "DirNeedToAdd\\geckodriver.exe");
			driver = new FirefoxDriver();
		}

		driver.manage().window().maximize();
		driver.manage().deleteAllCookies();
		driver.manage().timeouts().pageLoadTimeout(Utils.PAGE_LOAD_TIMEOUT, TimeUnit.SECONDS);
		driver.manage().timeouts().implicitlyWait(Utils.IMPLICIT_WAIT, TimeUnit.SECONDS);
		driver.get(Utils.getPropertyValue("URL"));
	}

	
//  @AfterSuite
//  public void TeardownTest() { 
//      driver.quit(); 
//  } 


}
