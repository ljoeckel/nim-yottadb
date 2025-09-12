What is the meaning / problem?
- Happens when test runs from "nimble test" only
- Uses **nim-2.0.8** Why?

/home/ljoeckel/git/nim-yottadb/src/tests/dsl_lock_test.nim(28, 4) template/generic instantiation of `awaitAll` from here
/home/ljoeckel/.nimble/pkgs2/malebolgia-0.1.0-5c404addea46d485f94915a897fba9906feff92d/malebolgia.nim(244, 5) template/generic instantiation of `checkBody` from here
/home/ljoeckel/git/nim-yottadb/src/tests/dsl_lock_test.nim(32, 14) template/generic instantiation of `spawn` from here
/home/ljoeckel/.nimble/pkgs2/malebolgia-0.1.0-5c404addea46d485f94915a897fba9906feff92d/malebolgia.nim(177, 47) template/generic instantiation of `toTask` from here
/home/ljoeckel/.nimble/pkgs2/nim-2.0.8-46333e8f4bda41dd6d3852a3f5fa4975b96b66a2/lib/std/tasks.nim(133, 20) template/generic instantiation of `isolate` from here
/home/ljoeckel/.nimble/pkgs2/nim-2.0.8-46333e8f4bda41dd6d3852a3f5fa4975b96b66a2/lib/std/isolation.nim(37, 14) template/generic instantiation of `=destroy` from here
/home/ljoeckel/.nimble/pkgs2/nim-2.0.8-46333e8f4bda41dd6d3852a3f5fa4975b96b66a2/lib/std/isolation.nim(27, 6) template/generic instantiation from here
/home/ljoeckel/.nimble/pkgs2/nim-2.0.8-46333e8f4bda41dd6d3852a3f5fa4975b96b66a2/lib/std/isolation.nim(29, 13) Warning: `=destroy`(dest.value) can raise an unlisted exception: Exception [Effect]
