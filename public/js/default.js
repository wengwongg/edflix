let extendedCheckboxes = new Map();

function toggleCheckboxes(checkboxesId) {
   if(!extendedCheckboxes.has(checkboxesId)) extendedCheckboxes.set(checkboxesId, false);

   if(extendedCheckboxes.get(checkboxesId)) {
       document.getElementById(checkboxesId + "-label").classList.remove("active");
       document.getElementById(checkboxesId).classList.remove("checkboxes-shown");
       extendedCheckboxes.set(checkboxesId, false);
   } else {
      document.getElementById(checkboxesId + "-label").classList.add("active");
      document.getElementById(checkboxesId).classList.add("checkboxes-shown")
      extendedCheckboxes.set(checkboxesId, true);
   }
}

function openMenu(){
   if(document.getElementById("menu").classList.contains('active')){
      document.getElementById("menu").classList.remove('active');
   } else {
      document.getElementById("menu").classList.add('active');
   }
}

function openSubMenu(menuName){
   let element = document.getElementById(menuName);
   let button = document.getElementById(menuName + "-btn")
   if(element.classList.contains('active')){
      button.classList.remove('active');
      element.classList.remove('active');
   } else {
      button.classList.add('active');
      element.classList.add('active');
   }
}

function confirmSubmit(formId, message){
   if (confirm(message)) {
      document.getElementById(formId).submit();
   }
}

function setGivenInputValue(inputId, value){
   document.getElementById(inputId).value = value;
}

function getValue(elementId) {
   console.log(document.getElementById(elementId).value);
   return document.getElementById(elementId).value;
}

function setPage(pageNo) {
   document.getElementById('page-no').value = pageNo.toString();
   refreshPage("main-form");
}

function refreshPage(formId) {
   document.getElementById(formId).submit();
}

function clearAllInputs(formId) {
   let form = document.getElementById(formId.toString())
   let allFormInputs = form.querySelectorAll("input, select")
   allFormInputs.forEach(function(item) {
      if ((item.nodeName === 'SELECT' || item.nodeName === 'INPUT')
          && !(item.type === 'reset' || item.type === 'submit' || item.type === 'button')) {
         item.value = "";
      }
   });
   form.submit();
}