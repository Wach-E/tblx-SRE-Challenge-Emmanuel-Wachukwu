from app import get_daimler_words

# Test the function coverted the webpage to a dictionary form
def test_daimler_wordlist_type():
  assert type(get_daimler_words()) == type(dict())

# Test the number of words are greater than 876 (as at the time of this test)
def test_daimler_words():
  assert len(get_daimler_words()) >= 876

# Test the leader word is daimler
def test_confirm_first_element():
  assert list(get_daimler_words().keys())[0] == 'daimler'
