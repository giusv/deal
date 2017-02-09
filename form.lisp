(defparameter *form*
 (let* ((user *user*)
	(name (input 'name :bind (user >> name)))
	(number (input 'number :bind (user >> numbers >> number)))
	(numbers (replicate number :bind (user >> numbers)))
	(city (input 'city :bind (user >> addresses >> address >> city)))
	(state (input 'state :bind (user >> addresses >> address >> state)))
	(addresses (replicate address :bind (user >> addresses)))
	(address (vert city state) :bind (user >> addresses >> address))
	(ok (button 'ok (const "Submit") :click ())))
   (form user (vert name addresses numbers))))

