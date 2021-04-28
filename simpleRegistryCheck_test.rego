package simpleRegistryCheck_test

import data.simpleRegistryCheck

test_mix_of_good_and_bad_images {
	in := {"request": {"object": {"spec": {"containers": [
		{"image": "docker.io/helloworld"},
		{"image": "busybox"},
	]}}}}

	simpleRegistryCheck.violation with input as in
}

test_bad_images {
	in := {"request": {"object": {"spec": {"containers": [{"image": "busybox"}]}}}}
	simpleRegistryCheck.violation with input as in
}

test_good_image_no_violation {
	in := {"request": {"object": {"spec": {"containers": [{"image": "docker.io/ff"}]}}}}
	not simpleRegistryCheck.violation with input as in
}

test_good_images_no_violation {
	in := {"request": {"object": {"spec": {"containers": [{"image": "docker.io/ff"}, {"image": "k8s.gcr.io/bar"}]}}}}
	not simpleRegistryCheck.violation with input as in
}
