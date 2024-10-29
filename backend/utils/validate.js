function validate(Fname, Lname, Phone, Password, Confirmpassword, Acctype) {
  if (/\s/.test(Fname)) {
    return "Name must not contain blank space";
  } else if (/[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/.test(Fname)) {
    return "Name must contain only alphabet letters";
  } else if (/\d/.test(Fname)) {
    return "Name must not contain any number";
  } else if (/[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/.test(Lname)) {
    return "Name must contain only alphabet letters";
  } else if (/\d/.test(Lname)) {
    return "Name must not contain any number";
  } else if (/\s/.test(Lname)) {
    return "Name must not contain blank space";
  } /* else if (!/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(Email)) {
    return "Invalid Email";
  } */ else if (!/^\+?\d{8,15}$/.test(Phone)) {
    return "Invalid Phone Number";
  } else if (/\s/.test(Password)) {
    return "Password must not contain blank space";
  } else if (!Password.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}$/)) {
    return "Incorrect Password";
  } else if (Password !== Confirmpassword) {
    return "Passwords donot match";
  } else if (
    !["admin", "owner", "manager", "trainer", "client"].includes(Acctype)
  ) {
    return "Invalid account type";
  } else {
    return undefined;
  }
}

function capitalize(Word) {
  if (!Word) {
    return;
  }
  return Word[0].toUpperCase() + Word.substring(1).toLowerCase();
}
module.exports = { validate, capitalize };
