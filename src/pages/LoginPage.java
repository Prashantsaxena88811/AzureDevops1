package pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class LoginPage {

	WebDriver driver;

	public LoginPage(WebDriver driver) {
		this.driver = driver;
	}

	// Locators
	@FindBy(id = "username") WebElement username;
	@FindBy(id = "password") WebElement password;
	@FindBy(id = "Login") WebElement Login;

	// Actions
	public String ValidateLoginPageTitle() {
		return driver.getTitle();
	}

	public void setUsername(String email) {
		username.sendKeys(email);

	}

	public void setPassword(String pass) {
		password.sendKeys(pass);

	}

	public void clickLogin() {
		Login.click();
	
	}

}
