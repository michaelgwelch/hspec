
-- | Importing this module allows you to use a QuickCheck property as an example
-- for a behavior. Use the 'property' function to indicate a QuickCkeck property.
--
-- > describe "cutTheDeck" [
-- >   it "puts the first half of a list after the last half"
-- >      (property $ \ xs -> let top = take (length xs `div` 2) xs
-- >                              bot = drop (length xs `div` 2) xs
-- >                          in cutTheDeck xs == bot ++ top),
-- >
-- >   it "restores an even sized list when cut twice"
-- >      (property $ \ xs -> even (length xs) ==> cutTheDeck (cutTheDeck xs) == xs)
-- >   ]
--
module Test.Hspec.QuickCheck (
  property
) where

import Test.Hspec.Internal
import qualified Test.QuickCheck as QC

data QuickCheckProperty a = QuickCheckProperty a

property :: QC.Testable a => a -> QuickCheckProperty a
property = QuickCheckProperty

instance QC.Testable t => SpecVerifier (QuickCheckProperty t) where
  it n (QuickCheckProperty p) = do
    r <- QC.quickCheckResult p
    case r of
      QC.Success {}           -> return (n, Success)
      f@(QC.Failure {})       -> return (n, Fail (QC.reason f))
      g@(QC.GaveUp {})        -> return (n, Fail ("Gave up after " ++ quantify (QC.numTests g) "test" ))
      QC.NoExpectedFailure {} -> return (n, Fail ("No expected failure"))
