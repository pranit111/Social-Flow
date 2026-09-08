import { FC } from 'react';
import { Web3ProviderInterface } from '@gitroom/frontend/components/launches/web3/web3.provider.interface';
import { WrapcasterProvider } from '@gitroom/frontend/components/launches/web3/providers/wrapcaster.provider';
import { MoltbookProvider } from '@gitroom/frontend/components/launches/web3/providers/moltbook.provider';
export const web3List: {
  identifier: string;
  component: FC<Web3ProviderInterface>;
}[] = [
  {
    identifier: 'wrapcast',
    component: WrapcasterProvider,
  },
  {
    identifier: 'moltbook',
    component: MoltbookProvider,
  },
];
